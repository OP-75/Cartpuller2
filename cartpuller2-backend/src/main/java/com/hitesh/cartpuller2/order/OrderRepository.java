package com.hitesh.cartpuller2.order;

import java.util.List;

import org.springframework.data.mongodb.core.geo.GeoJsonPoint;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

public interface OrderRepository extends MongoRepository<Order, String> {
    List<Order> findByOrderStatus(OrderStatus orderStatus);

    List<Order> findByCartpullerEmail(String cartpullerEmail);

    List<Order> findByRiderEmail(String cartpullerEmail);

    List<Order> findByCustomerEmail(String customerEmail);

    List<Order> findByCartpullerEmailAndOrderStatus(String cartpullerEmail, OrderStatus orderStatus);

    List<Order> findByRiderEmailAndOrderStatus(String riderEmail, OrderStatus orderStatus);

    @Query("{'deliveryLocation': {$nearSphere: ?0, $maxDistance: ?1}, 'orderStatus': ?2}")
    List<Order> findByLocationNearAndOrderStatus(GeoJsonPoint location, double maxDistance,
            OrderStatus orderStatus);

}
