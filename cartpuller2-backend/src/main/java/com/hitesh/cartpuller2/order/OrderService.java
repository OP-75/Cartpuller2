package com.hitesh.cartpuller2.order;

import java.util.Map;

import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;

    public Order createOrder(Map<String, Integer> cart, String customerEmail) {

        Order order = new Order();

        order.setOrderDetails(cart);
        order.setCustomerEmail(customerEmail);
        order.setOrderStatus(OrderStatus.SENT);

        order = orderRepository.save(order);

        return order;
    }

}
