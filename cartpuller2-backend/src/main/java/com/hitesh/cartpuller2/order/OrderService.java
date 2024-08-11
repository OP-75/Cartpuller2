package com.hitesh.cartpuller2.order;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

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

    public Order createOrder(Map<String, Integer> cart, String customerEmail) {

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
        order.setDeliveryLatitude(user.getLatitude());
        order.setDeliveryLongitude(user.getLongitude());

        order = orderRepository.save(order);

        return order;
    }

    public List<Order> getByOrderStatus(OrderStatus status) {
        return orderRepository.findByOrderStatus(status);
    }

    public Order getByOrderId(String id) {
        return orderRepository.findById(id).orElseThrow();
    }

    public List<Order> getOrderByCartpullerEmail(String cartpullerEmail) {
        return orderRepository.findByCartpullerEmail(cartpullerEmail);
    }

    public List<Order> getOrderByRiderEmail(String riderEmail) {
        return orderRepository.findByRiderEmail(riderEmail);
    }

    public Order updateOrder(Order newOrder) {
        // since repository has no way to update order we will delete and then save new
        // order
        String orderId = newOrder.getId();
        orderRepository.deleteById(orderId);
        return orderRepository.save(newOrder);
    }

}
