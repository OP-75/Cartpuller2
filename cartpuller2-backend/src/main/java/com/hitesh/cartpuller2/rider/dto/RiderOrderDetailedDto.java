package com.hitesh.cartpuller2.rider.dto;

import java.io.Serializable;
import java.util.Map;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.MongoId;

import com.hitesh.cartpuller2.order.OrderStatus;
import com.hitesh.cartpuller2.vegetable.Vegetable;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RiderOrderDetailedDto implements Serializable {
    @Id
    @MongoId
    private String id;

    private Map<String, Integer> orderDetails; // vegetable id - quantity, map
    private Map<String, Vegetable> vegetableDetailMap; // vegetable id - obj, map, we get this internally
    private OrderStatus orderStatus; // enum

    private String customerNumber;
    private String customerName;

    private String cartpullerNumber;
    private String cartpullerName;

    private String pickupLatitude;
    private String pickupLongitude;

    private String deliveryAddress;
    private String deliveryLatitude;
    private String deliveryLongitude;
}
