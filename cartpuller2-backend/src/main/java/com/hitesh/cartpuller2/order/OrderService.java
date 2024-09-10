package com.hitesh.cartpuller2.order;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.mongodb.core.geo.GeoJsonPoint;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.hitesh.cartpuller2.order.dto.OrderDto;
import com.hitesh.cartpuller2.user.User;
import com.hitesh.cartpuller2.user.service.UserService;
import com.hitesh.cartpuller2.vegetable.Vegetable;
import com.hitesh.cartpuller2.vegetable.VegetableService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final VegetableService vegetableService;
    private final UserService userService;

    public OrderDto createOrder(Map<String, Integer> cart, String customerEmail) {

        User user = userService.getUserByEmail(customerEmail);

        Order order = new Order();

        order.setOrderDetails(cart);

        Map<String, Vegetable> idVeggieMap = new HashMap<>();
        for (String id : cart.keySet()) {
            idVeggieMap.put(id, vegetableService.getVegeableById(id));
        }
        order.setVegetableDetailMap(idVeggieMap);

        order.setCustomerEmail(customerEmail);
        order.setOrderStatus(OrderStatus.SENT);
        order.setDeliveryAddress(user.getAddress());

        double x = Double.parseDouble(user.getLongitude());
        double y = Double.parseDouble(user.getLatitude());

        order.setDeliveryLocation(new GeoJsonPoint(x, y));

        order = orderRepository.save(order);

        return getOrderDto(order);
    }

    @Cacheable(value = "ordersByStatus", key = "#status")
    public List<OrderDto> getByOrderStatus(OrderStatus status) {
        return orderRepository.findByOrderStatus(status).stream().map((order) -> getOrderDto(order))
                .collect(Collectors.toList());
    }

    @Cacheable(value = "orders", key = "#id")
    public Order getByOrderId(String id) {
        return orderRepository.findById(id).orElseThrow();
    }

    @Cacheable(value = "orderDtos", key = "#id")
    public OrderDto getDtoByOrderId(String id) {
        return getOrderDto(orderRepository.findById(id).orElseThrow());
    }

    public List<OrderDto> getOrderDtosByLocationAndStatus(GeoJsonPoint nearLocation, double distanceInMeters,
            OrderStatus status) {
        return orderRepository.findByLocationNearAndOrderStatus(nearLocation, distanceInMeters, status).stream()
                .map((order) -> getOrderDto(order))
                .collect(Collectors.toList());
    }

    @Cacheable(value = "orderOfCartpullers", key = "#cartpullerEmail")
    public List<OrderDto> getOrderByCartpullerEmail(String cartpullerEmail) {
        return orderRepository.findByCartpullerEmail(cartpullerEmail).stream().map((order) -> getOrderDto(order))
                .collect(Collectors.toList());
    }

    @Cacheable(value = "orderOfRiders", key = "#riderEmail")
    public List<OrderDto> getOrderByRiderEmail(String riderEmail) {
        return orderRepository.findByRiderEmail(riderEmail).stream().map((order) -> getOrderDto(order))
                .collect(Collectors.toList());
    }

    @Cacheable(value = "orderOfCustomers", key = "#customerEmail")
    public List<OrderDto> getOrderByCustomerEmail(String customerEmail) {
        return orderRepository.findByCustomerEmail(customerEmail).stream().map((order) -> getOrderDto(order))
                .collect(Collectors.toList());
    }

    @CacheEvict(value = { "orderOfCustomers", "orderOfRiders", "orderOfCartpullers", "orderDtos", "orders",
            "ordersByStatus" }, allEntries = true)
    @Transactional
    public OrderDto updateOrder(Order newOrder) {
        // since repository has no way to update order we will delete and then save new
        // order
        String orderId = newOrder.getId();
        orderRepository.deleteById(orderId);
        return getOrderDto(orderRepository.save(newOrder));
    }

    public boolean doesCartpullerHaveActiveOrders(String cartpullerEmail) {
        List<Order> activeOrders = new ArrayList<>();

        activeOrders.addAll(orderRepository.findByCartpullerEmailAndOrderStatus(cartpullerEmail, OrderStatus.ACCEPTED));
        activeOrders.addAll(
                orderRepository.findByCartpullerEmailAndOrderStatus(cartpullerEmail, OrderStatus.RIDER_ASSIGNED));

        return !activeOrders.isEmpty();
    }

    public boolean doesRiderHaveActiveOrders(String riderEmail) {
        List<Order> activeOrders = new ArrayList<>();

        activeOrders.addAll(orderRepository.findByRiderEmailAndOrderStatus(riderEmail, OrderStatus.RIDER_ASSIGNED));
        activeOrders
                .addAll(orderRepository.findByRiderEmailAndOrderStatus(riderEmail, OrderStatus.DELIVERY_IN_PROGRESS));

        return !activeOrders.isEmpty();
    }

    public OrderDto getOrderDto(Order order) {
        if (order == null) {
            return null;
        }

        OrderDto orderDto = new OrderDto();
        orderDto.setId(order.getId());
        orderDto.setOrderDetails(order.getOrderDetails());
        orderDto.setVegetableDetailMap(order.getVegetableDetailMap());
        orderDto.setCustomerEmail(order.getCustomerEmail());
        orderDto.setOrderStatus(order.getOrderStatus());
        orderDto.setRiderEmail(order.getRiderEmail());
        orderDto.setCartpullerEmail(order.getCartpullerEmail());
        orderDto.setDeliveryAddress(order.getDeliveryAddress());

        orderDto.setDeliveryLatitude(String.valueOf(order.getDeliveryLocation().getY()));
        orderDto.setDeliveryLongitude(String.valueOf(order.getDeliveryLocation().getX()));

        return orderDto;
    }

}
