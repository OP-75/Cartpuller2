package com.hitesh.cartpuller2.order.dto;

import java.util.*;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.MongoId;

import java.io.Serializable;
import com.hitesh.cartpuller2.vegetable.Vegetable;
import com.hitesh.cartpuller2.order.OrderStatus;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class OrderDto implements Serializable {

    // ! This is created do that i dont have to make changes in frontend for
    // ! deliveryLongitude, deliveryLatitude

    @Id
    @MongoId
    private String id;

    private Map<String, Integer> orderDetails; // vegetable id - quantity, map
    private Map<String, Vegetable> vegetableDetailMap; // vegetable id - obj, map, we get this internally

    private String customerEmail;
    private OrderStatus orderStatus; // enum

    private String riderEmail;
    private String cartpullerEmail;

    private String deliveryAddress;
    private String deliveryLatitude;
    private String deliveryLongitude;

}
