package com.hitesh.cartpuller2.rider;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.hitesh.cartpuller2.cartpuller.ActiveCartpuller;
import com.hitesh.cartpuller2.cartpuller.CartpullerService;
import com.hitesh.cartpuller2.global.dto.Activity;
import com.hitesh.cartpuller2.global.dto.Location;
import com.hitesh.cartpuller2.order.Order;
import com.hitesh.cartpuller2.order.OrderService;
import com.hitesh.cartpuller2.order.OrderStatus;
import com.hitesh.cartpuller2.rider.dto.RiderOrderDeliveryDto;
import com.hitesh.cartpuller2.rider.dto.RiderOrderRedactedDto;
import com.hitesh.cartpuller2.rider.exception.RiderAlreadyAssignedException;
import com.hitesh.cartpuller2.rider.exception.RiderInactiveException;
import com.hitesh.cartpuller2.service.HelperService;
import com.hitesh.cartpuller2.user.User;
import com.hitesh.cartpuller2.user.service.UserService;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class RiderService {

    private final UserService userService;
    private final OrderService orderService;
    private final HelperService helperService;
    private final ActiveRiderRepository activeRiderRepository;
    private final CartpullerService cartpullerService;

    public void activateRider(Location location, HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        Optional<ActiveRider> optionalRider = activeRiderRepository.findByEmail(email);
        if (optionalRider.isPresent()) {
            // if rider alredy in table delete old one and set new one
            ActiveRider oldRider = optionalRider.get();
            activeRiderRepository.delete(oldRider);

            oldRider.setStartedOn(new Date());
            ActiveRider newRider = oldRider;
            activeRiderRepository.insert(newRider);

            return;
        }

        final User user = userService.getUserByEmail(email);

        ActiveRider cartpuller = new ActiveRider(email,
                new Date(),
                user.getName(),
                user.getPhoneNumber(),
                user.getAddress(),
                location.getLongitude(),
                location.getLatitude());

        activeRiderRepository.save(cartpuller);

    }

    public void deactivateRider(HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        Optional<ActiveRider> optionalRider = activeRiderRepository.findByEmail(email);
        if (optionalRider.isPresent()) {
            activeRiderRepository.delete(optionalRider.get());
        }
    }

    public void updateRiderLocation(Location location, HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        Optional<ActiveRider> optionalCartpuller = activeRiderRepository.findByEmail(email);
        if (optionalCartpuller.isPresent()) {
            // get old cartpuller and delete it, then save new cart puller with location
            ActiveRider oldRider = optionalCartpuller.get();
            activeRiderRepository.delete(oldRider);

            oldRider.setLongitude(location.getLongitude());
            oldRider.setLatitude(location.getLatitude());
            ActiveRider newCartpuller = oldRider;
            activeRiderRepository.insert(newCartpuller);

            return;
        } else {
            throw new RiderInactiveException("Rider is inactive");
        }
    }

    public Activity checkActive(HttpServletRequest request) {
        String email = helperService.getEmailFromRequest(request);
        if (activeRiderRepository.findByEmail(email).isPresent()) {
            return new Activity(true);
        } else {
            return new Activity(false);
        }
    }

    public List<RiderOrderDeliveryDto> getOrdersIfActive(HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        if (!isRiderActive(email)) {
            throw new RiderInactiveException("Please activate get orders");
        }

        List<Order> orders = orderService.getByOrderStatus(OrderStatus.ACCEPTED);
        List<RiderOrderDeliveryDto> ordersDto = new ArrayList<>();
        for (Order order : orders) {
            ordersDto.add(getRiderOrderDeliveryDtoFromOrder(order));
        }
        return ordersDto;
    }

    public List<RiderOrderRedactedDto> getPastOrders(HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        List<Order> orders = orderService.getOrderByRiderEmail(email);

        List<RiderOrderRedactedDto> ordersDto = new ArrayList<>();
        for (Order order : orders) {
            ordersDto.add(getRiderOrderRedactedDto(order));
        }
        return ordersDto;

    }

    public RiderOrderDeliveryDto acceptOrderIfActive(HttpServletRequest request, String orderId) {
        final String riderEmail = helperService.getEmailFromRequest(request);

        if (!isRiderActive(riderEmail)) {
            throw new RiderInactiveException("Please activate get orders");
        }

        Order order = orderService.getByOrderId(orderId);
        if (!order.getOrderStatus().equals(OrderStatus.ACCEPTED)) {
            // ie if order status is anything other than ACCEPTED like already
            // RIDER_ASSIGNED,DELIVERY_IN_PROGRESS or DELIVERED then throw error
            throw new RiderAlreadyAssignedException("This order has already been assigned to another rider");
        }

        order.setRiderEmail(riderEmail);
        order.setOrderStatus(OrderStatus.RIDER_ASSIGNED);

        Order updatedOrder = orderService.updateOrder(order);

        return getRiderOrderDeliveryDtoFromOrder(updatedOrder);

    }

    // ----------------private methods-----------------------
    private RiderOrderRedactedDto getRiderOrderRedactedDto(Order order) {
        return new RiderOrderRedactedDto(order.getId(), order.getOrderStatus());
    }

    private RiderOrderDeliveryDto getRiderOrderDeliveryDtoFromOrder(Order order) {

        User customer = userService.getUserByEmail(order.getCustomerEmail());
        User cartpuller = userService.getUserByEmail(order.getCartpullerEmail());
        // for cartpuller location
        ActiveCartpuller activeCartpullerDetails = cartpullerService.getActiveCartpuller(order.getCartpullerEmail());

        return new RiderOrderDeliveryDto(order.getId(), order.getOrderDetails(), order.getVegetableDetailMap(),
                order.getOrderStatus(), customer.getPhoneNumber(), customer.getName(), cartpuller.getPhoneNumber(),
                cartpuller.getName(), activeCartpullerDetails.getLatitude(), activeCartpullerDetails.getLongitude(),
                customer.getAddress(), customer.getLatitude(), customer.getLongitude());
    }

    private boolean isRiderActive(String email) {
        return activeRiderRepository.findByEmail(email).isPresent();
    }

}
