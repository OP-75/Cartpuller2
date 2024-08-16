package com.hitesh.cartpuller2.customer;

import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Service;
import com.hitesh.cartpuller2.cartpuller.ActiveCartpuller;
import com.hitesh.cartpuller2.cartpuller.CartpullerService;
import com.hitesh.cartpuller2.customer.dto.DetailedOrderDto;
import com.hitesh.cartpuller2.order.Order;
import com.hitesh.cartpuller2.order.OrderService;
import com.hitesh.cartpuller2.order.OrderStatus;
import com.hitesh.cartpuller2.rider.ActiveRider;
import com.hitesh.cartpuller2.rider.RiderService;
import com.hitesh.cartpuller2.rider.dto.RedactedOrderDto;
import com.hitesh.cartpuller2.rider.exception.AuthorizationException;
import com.hitesh.cartpuller2.service.HelperService;
import com.hitesh.cartpuller2.user.User;
import com.hitesh.cartpuller2.user.service.UserService;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class CustomerService {

    private final OrderService orderService;
    private final HelperService helperService;
    private final UserService userService;
    private final CartpullerService cartpullerService;
    private final RiderService riderService;

    public List<RedactedOrderDto> getPastOrders(HttpServletRequest request) {
        String customerEmail = helperService.getEmailFromRequest(request);

        List<Order> orders = orderService.getOrderByCustomerEmail(customerEmail);

        List<RedactedOrderDto> dtos = new ArrayList<>();
        for (Order order : orders) {
            dtos.add(getRedactedDto(order));
        }

        return dtos;

    }

    public DetailedOrderDto getOrderDetails(HttpServletRequest request, String orderId) {
        // first check if order is made by customer from jwt & delivery status !=
        // Deliveredif it is delivered then null the location of cartpuller and rider

        String customerEmail = helperService.getEmailFromRequest(request);
        Order order = orderService.getByOrderId(orderId);

        if (order.getCustomerEmail().equals(customerEmail)) {

            DetailedOrderDto dto = getRiderOrderDetailedDto(order);

            if (dto.getOrderStatus().equals(OrderStatus.DELIVERED)) {
                dto.setCartpullerLatitude(null);
                dto.setCartpullerLongitude(null);
                dto.setRiderLatitude(null);
                dto.setRiderLongitude(null);
            }

            return dto;

        } else {
            throw new AuthorizationException("You dont have proper authorization");
        }

    }

    private DetailedOrderDto getRiderOrderDetailedDto(Order order) {

        User cartpuller = new User(null); // initailze as empty object
        if (order.getCartpullerEmail() != null) {
            cartpuller = userService.getUserByEmail(order.getCartpullerEmail());
        }
        User rider = new User(null);
        if (order.getRiderEmail() != null) {
            rider = userService.getUserByEmail(order.getRiderEmail());
        }

        String cartpullerLatitude = null;
        String cartpullerLongitude = null;
        String riderLatitude = null;
        String riderLongitude = null;

        try {
            // for live cartpuller location
            ActiveCartpuller activeCartpullerDetails = cartpullerService
                    .getActiveCartpuller(order.getCartpullerEmail());

            cartpullerLatitude = activeCartpullerDetails.getLatitude();
            cartpullerLongitude = activeCartpullerDetails.getLongitude();

        } catch (Exception e) {
            log.error("Error in getting active cartpuller", e);
        }

        try {
            // for live cartpuller location
            ActiveRider activeRiderDetails = riderService.getActiveRiderByEmail(order.getRiderEmail());
            riderLatitude = activeRiderDetails.getLatitude();
            riderLongitude = activeRiderDetails.getLongitude();
        } catch (Exception e) {
            log.error("Error in getting active rider", e);
        }

        DetailedOrderDto dto = new DetailedOrderDto(order.getId(), order.getOrderDetails(),
                order.getVegetableDetailMap(),
                order.getOrderStatus(), cartpuller.getName(), cartpuller.getPhoneNumber(), cartpullerLatitude,
                cartpullerLongitude, rider.getName(), rider.getPhoneNumber(), riderLatitude, riderLongitude,
                order.getDeliveryAddress(), order.getDeliveryLatitude(), order.getDeliveryLongitude());

        return dto;
    }

    private RedactedOrderDto getRedactedDto(Order order) {
        return new RedactedOrderDto(order.getId(), order.getOrderStatus());
    }

}
