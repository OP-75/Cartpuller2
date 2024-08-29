package com.hitesh.cartpuller2.cartpuller;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.hitesh.cartpuller2.cartpuller.dto.OrderDto;
import com.hitesh.cartpuller2.cartpuller.exception.CartpullerNotActivatedException;
import com.hitesh.cartpuller2.cartpuller.exception.CartpullerOrderAlreadyAcceptedException;
import com.hitesh.cartpuller2.cartpuller.exception.CartpullerDeactivationFailedException;
import com.hitesh.cartpuller2.global.dto.Activity;
import com.hitesh.cartpuller2.global.dto.Location;
import com.hitesh.cartpuller2.order.Order;
import com.hitesh.cartpuller2.order.OrderService;
import com.hitesh.cartpuller2.order.OrderStatus;
import com.hitesh.cartpuller2.service.HelperService;
import com.hitesh.cartpuller2.user.User;
import com.hitesh.cartpuller2.user.service.UserService;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class CartpullerService {

    private final UserService userService;
    private final OrderService orderService;
    private final HelperService helperService;
    private final ActiveCartpullerRepository activeCartpullerRepository;

    public void activateCartpuller(Location location, HttpServletRequest request) {

        final String email = helperService.getEmailFromRequest(request);

        Optional<ActiveCartpuller> optionalCartpuller = activeCartpullerRepository.findByEmail(email);
        if (optionalCartpuller.isPresent()) {
            // if cartpuller alredy in table delete old one and set new one
            ActiveCartpuller oldCartpuller = optionalCartpuller.get();
            activeCartpullerRepository.delete(oldCartpuller);

            oldCartpuller.setStartedOn(new Date());
            ActiveCartpuller newCartpuller = oldCartpuller;
            activeCartpullerRepository.insert(newCartpuller);

            return;
        }

        final User user = userService.getUserByEmail(email);

        ActiveCartpuller cartpuller = new ActiveCartpuller(email,
                new Date(),
                user.getName(),
                user.getPhoneNumber(),
                user.getAddress(),
                location.getLongitude(),
                location.getLatitude());

        activeCartpullerRepository.save(cartpuller);

    }

    public void deactivateCartpuller(HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        if (orderService.doesCartpullerHaveActiveOrders(email)) {
            throw new CartpullerDeactivationFailedException("Deactivation unsucessful, you still have active orders");
        }

        Optional<ActiveCartpuller> optionalCartpuller = activeCartpullerRepository.findByEmail(email);
        if (optionalCartpuller.isPresent()) {
            activeCartpullerRepository.delete(optionalCartpuller.get());
        }
    }

    public void updateCartpullerLocation(Location location, HttpServletRequest request) {

        final String email = helperService.getEmailFromRequest(request);

        Optional<ActiveCartpuller> optionalCartpuller = activeCartpullerRepository.findByEmail(email);
        if (optionalCartpuller.isPresent()) {
            // get old cartpuller and delete it, then save new cart puller with location
            ActiveCartpuller oldCartpuller = optionalCartpuller.get();
            activeCartpullerRepository.delete(oldCartpuller);

            oldCartpuller.setLongitude(location.getLongitude());
            oldCartpuller.setLatitude(location.getLatitude());
            ActiveCartpuller newCartpuller = oldCartpuller;
            activeCartpullerRepository.insert(newCartpuller);

            return;
        } else {
            throw new CartpullerNotActivatedException("Cartpuller is inactive");
        }
    }

    public List<OrderDto> getOrdersIfActive(HttpServletRequest request) {

        final String email = helperService.getEmailFromRequest(request);

        if (!isCartpullerActive(email)) {
            throw new CartpullerNotActivatedException("Please activate your store in app to get orders");
        }

        List<Order> orders = orderService.getByOrderStatus(OrderStatus.SENT);
        List<OrderDto> ordersDto = new ArrayList<>();
        for (Order order : orders) {
            ordersDto.add(getOrderDtoFromOrder(order));
        }
        return ordersDto;
    }

    public List<OrderDto> getCartpullerPastOrders(HttpServletRequest request) {
        // if an order has cartpuller email that means it was accepted
        final String email = helperService.getEmailFromRequest(request);

        List<Order> orders = orderService.getOrderByCartpullerEmail(email);
        List<OrderDto> ordersDto = new ArrayList<>();
        for (Order order : orders) {
            ordersDto.add(getOrderDtoFromOrder(order));
        }
        return ordersDto;
    }

    public OrderDto acceptOrderIfActive(HttpServletRequest request, String orderId) {

        final String cartpullerEmail = helperService.getEmailFromRequest(request);

        if (!isCartpullerActive(cartpullerEmail)) {
            throw new CartpullerNotActivatedException("Please activate your store in app to get orders");
        }

        Order order = orderService.getByOrderId(orderId);
        if (!order.getOrderStatus().equals(OrderStatus.SENT)) {
            // ie if order status is anything other than SENT like already
            // ACCEPTED,RIDER_ASSIGNED,DELIVERY_IN_PROGRESS or DELIVERED then throw error
            throw new CartpullerOrderAlreadyAcceptedException(
                    "Order has already been accepted by someone else, hence no longer available");
        }

        order.setCartpullerEmail(cartpullerEmail);
        order.setOrderStatus(OrderStatus.ACCEPTED);

        Order updatedOrder = orderService.updateOrder(order);

        return getOrderDtoFromOrder(updatedOrder);

    }

    public boolean isCartpullerActive(String email) {
        return activeCartpullerRepository.findByEmail(email).isPresent();
    }

    public ActiveCartpuller getActiveCartpuller(String email) {
        return activeCartpullerRepository.findByEmail(email).get();
    }

    private OrderDto getOrderDtoFromOrder(Order order) {
        return new OrderDto(order.getId(), order.getOrderDetails(), order.getVegetableDetailMap(),
                order.getOrderStatus());
    }

    public Activity checkActive(HttpServletRequest request) {
        String email = helperService.getEmailFromRequest(request);
        if (activeCartpullerRepository.findByEmail(email).isPresent()) {
            return new Activity(true);
        } else {
            return new Activity(false);
        }
    }
}
