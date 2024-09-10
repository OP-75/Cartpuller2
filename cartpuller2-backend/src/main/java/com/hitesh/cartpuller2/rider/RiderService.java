package com.hitesh.cartpuller2.rider;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.mongodb.core.geo.GeoJsonPoint;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.hitesh.cartpuller2.cartpuller.CartpullerService;
import com.hitesh.cartpuller2.cartpuller.dto.ActiveCartpullerDto;
import com.hitesh.cartpuller2.global.dto.Activity;
import com.hitesh.cartpuller2.global.dto.Location;
import com.hitesh.cartpuller2.order.Order;
import com.hitesh.cartpuller2.order.OrderService;
import com.hitesh.cartpuller2.order.OrderStatus;
import com.hitesh.cartpuller2.order.dto.OrderDto;
import com.hitesh.cartpuller2.rider.dto.ActiveRiderDto;
import com.hitesh.cartpuller2.rider.dto.DetailedOrderDto;
import com.hitesh.cartpuller2.rider.dto.RedactedOrderDto;
import com.hitesh.cartpuller2.rider.exception.AuthorizationException;
import com.hitesh.cartpuller2.rider.exception.BadRequestException;
import com.hitesh.cartpuller2.rider.exception.RiderDeactivationFailedException;
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
    public final HelperService helperService;
    private final ActiveRiderRepository activeRiderRepository;
    private final CartpullerService cartpullerService;
    private final double maxDistance = 4000;

    @Cacheable(value = "activeRiderDto", key = "#email")
    public ActiveRiderDto getActiveRiderByEmail(String email) {
        return toActiveRiderDto(activeRiderRepository.findByEmail(email).get());
    }

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

        double x = Double.parseDouble(location.getLongitude());
        double y = Double.parseDouble(location.getLatitude());
        GeoJsonPoint locGeoJsonPoint = new GeoJsonPoint(x, y);

        ActiveRider cartpuller = new ActiveRider(email,
                new Date(),
                user.getName(),
                user.getPhoneNumber(),
                user.getAddress(),
                locGeoJsonPoint);

        activeRiderRepository.save(cartpuller);

    }

    @Transactional
    @CacheEvict(value = "activeRiderDto", key = "#root.target.helperService.getEmailFromRequest(#request)")
    // #root.method, #root.target, and #root.caches for references to the method,
    // target object, and affected cache(s) respectively.
    public void deactivateRider(HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        if (orderService.doesRiderHaveActiveOrders(email)) {
            throw new RiderDeactivationFailedException("Deactivation unsucessful, you still have active orders");
        }

        Optional<ActiveRider> optionalRider = activeRiderRepository.findByEmail(email);
        if (optionalRider.isPresent()) {
            activeRiderRepository.delete(optionalRider.get());
        }
    }

    @Transactional
    @CachePut(value = "activeRiderDto", key = "#result.email")
    // `#result` for a reference to the result of the method invocation
    public ActiveRiderDto updateRiderLocation(Location location, HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        Optional<ActiveRider> optionalCartpuller = activeRiderRepository.findByEmail(email);
        if (optionalCartpuller.isPresent()) {
            // get old rider and delete it, then save new rider with location
            ActiveRider oldRider = optionalCartpuller.get();
            activeRiderRepository.delete(oldRider);

            double x = Double.parseDouble(location.getLongitude());
            double y = Double.parseDouble(location.getLatitude());
            GeoJsonPoint locGeoJsonPoint = new GeoJsonPoint(x, y);

            oldRider.setLocation(locGeoJsonPoint);

            // oldRider is now updated
            activeRiderRepository.insert(oldRider);

            return toActiveRiderDto(oldRider);
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

    public List<DetailedOrderDto> getOrdersIfActive(HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        Optional<ActiveRider> rider = getRider(email);
        if (!rider.isPresent()) {
            throw new RiderInactiveException("Please activate get orders");
        }

        List<OrderDto> orders = orderService.getOrderDtosByLocationAndStatus(rider.get().getLocation(), maxDistance,
                OrderStatus.ACCEPTED);
        List<DetailedOrderDto> ordersDto = new ArrayList<>();
        for (OrderDto order : orders) {
            ordersDto.add(getRiderOrderDetailedDto(order));
        }
        return ordersDto;
    }

    public List<RedactedOrderDto> getPastOrders(HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        List<OrderDto> orders = orderService.getOrderByRiderEmail(email);

        List<RedactedOrderDto> ordersDto = new ArrayList<>();
        for (OrderDto order : orders) {
            ordersDto.add(getRiderOrderRedactedDto(order));
        }
        return ordersDto;

    }

    public DetailedOrderDto acceptOrderIfActive(HttpServletRequest request, String orderId) {
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

        OrderDto updatedOrder = orderService.updateOrder(order);

        return getRiderOrderDetailedDto(updatedOrder);

    }

    public DetailedOrderDto getAccepedOrderDetails(HttpServletRequest request, String orderId) {
        // first check if order is assigned to rider & delivery status = RIDER_ASSIGNED
        // or DELIVERY_IN_PROGRESS, before returning

        String riderEmail = helperService.getEmailFromRequest(request);
        OrderDto order;
        try {
            order = orderService.getDtoByOrderId(orderId);
        } catch (NoSuchElementException e) {
            throw new BadRequestException("No order can be found with the given ID");
        }

        if (order.getRiderEmail().equals(riderEmail) && (order.getOrderStatus().equals(OrderStatus.RIDER_ASSIGNED)
                || order.getOrderStatus().equals(OrderStatus.DELIVERY_IN_PROGRESS))) {

            return getRiderOrderDetailedDto(order);

        } else {
            throw new AuthorizationException("You dont have proper authorization");
        }

    }

    public DetailedOrderDto pickupOrderIfActive(HttpServletRequest request, String orderId) {
        final String riderEmail = helperService.getEmailFromRequest(request);

        if (!isRiderActive(riderEmail)) {
            throw new RiderInactiveException("Please activate get orders");
        }

        Order order = orderService.getByOrderId(orderId);
        if (!order.getRiderEmail().equals(riderEmail)) {
            // ie if rider email in order!=email in jwt
            throw new RiderAlreadyAssignedException("This order has already been assigned to another rider");
        }

        order.setOrderStatus(OrderStatus.DELIVERY_IN_PROGRESS);

        OrderDto updatedOrder = orderService.updateOrder(order);

        return getRiderOrderDetailedDto(updatedOrder);

    }

    public RedactedOrderDto deliverOrderIfActive(HttpServletRequest request, String orderId) {
        final String riderEmail = helperService.getEmailFromRequest(request);

        if (!isRiderActive(riderEmail)) {
            throw new RiderInactiveException("Please activate get orders");
        }

        Order order = orderService.getByOrderId(orderId);
        if (!order.getRiderEmail().equals(riderEmail)) {
            // ie if rider email in order!=email in jwt
            throw new RiderAlreadyAssignedException("This order has already been assigned to another rider");
        }

        order.setOrderStatus(OrderStatus.DELIVERED);

        OrderDto updatedOrder = orderService.updateOrder(order);

        return getRiderOrderRedactedDto(updatedOrder);

    }

    public ActiveRiderDto toActiveRiderDto(ActiveRider activeRider) {
        if (activeRider == null) {
            return null;
        }

        ActiveRiderDto dto = new ActiveRiderDto(activeRider.getEmail());
        dto.setId(activeRider.getId());
        dto.setStartedOn(activeRider.getStartedOn());
        dto.setName(activeRider.getName());
        dto.setPhoneNumber(activeRider.getPhoneNumber());
        dto.setAddress(activeRider.getAddress());

        if (activeRider.getLocation() != null) {
            dto.setLongitude(String.valueOf(activeRider.getLocation().getX()));
            dto.setLatitude(String.valueOf(activeRider.getLocation().getY()));
        } else {
            dto.setLongitude(null);
            dto.setLatitude(null);
        }

        return dto;
    }

    // ----------------private methods-----------------------
    private RedactedOrderDto getRiderOrderRedactedDto(OrderDto order) {
        return new RedactedOrderDto(order.getId(), order.getOrderStatus());
    }

    private DetailedOrderDto getRiderOrderDetailedDto(OrderDto order) {

        User customer = userService.getUserByEmail(order.getCustomerEmail());
        User cartpuller = userService.getUserByEmail(order.getCartpullerEmail());
        // for cartpuller location
        ActiveCartpullerDto activeCartpullerDetails = cartpullerService.getActiveCartpuller(order.getCartpullerEmail());

        return new DetailedOrderDto(order.getId(), order.getOrderDetails(), order.getVegetableDetailMap(),
                order.getOrderStatus(), customer.getPhoneNumber(), customer.getName(), cartpuller.getPhoneNumber(),
                cartpuller.getName(), activeCartpullerDetails.getLatitude(), activeCartpullerDetails.getLongitude(),
                customer.getAddress(), customer.getLatitude(), customer.getLongitude());
    }

    private boolean isRiderActive(String email) {
        return activeRiderRepository.findByEmail(email).isPresent();
    }

    private Optional<ActiveRider> getRider(String email) {
        return activeRiderRepository.findByEmail(email);
    }

}
