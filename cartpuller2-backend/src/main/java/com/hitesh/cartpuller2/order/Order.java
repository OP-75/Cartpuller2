package com.hitesh.cartpuller2.order;

import java.util.*;

import java.io.Serializable;

import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.MongoId;

import lombok.Data;

@Data
@Document(collection = "Orders")
public class Order implements Serializable {

    @MongoId
    private String id;

    private Map<String, Integer> orderDetails; // vegetable id - quantity, map
    private String customerEmail;
    private OrderStatus orderStatus;

    private String riderEmail;
    private String cartpullerEmail;

}
