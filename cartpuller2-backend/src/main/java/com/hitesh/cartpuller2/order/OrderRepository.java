package com.hitesh.cartpuller2.order;

import java.util.List;

import org.springframework.data.mongodb.repository.MongoRepository;

public interface OrderRepository extends MongoRepository<Order, String> {
    List<Order> findByOrderStatus(OrderStatus orderStatus);

    List<Order> findByCartpullerEmail(String cartpullerEmail);

    List<Order> findByRiderEmail(String cartpullerEmail);

    List<Order> findByCustomerEmail(String customerEmail);

}
