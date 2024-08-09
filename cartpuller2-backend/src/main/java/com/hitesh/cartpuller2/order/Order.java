package com.hitesh.cartpuller2.order;

import java.util.*;

import java.io.Serializable;

import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.MongoId;

import com.hitesh.cartpuller2.vegetable.Vegetable;

import lombok.Data;

@Data
@Document(collection = "Orders")
public class Order implements Serializable {

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
