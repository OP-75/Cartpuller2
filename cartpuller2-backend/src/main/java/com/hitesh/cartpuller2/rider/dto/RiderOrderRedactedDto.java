package com.hitesh.cartpuller2.rider.dto;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.MongoId;

import com.hitesh.cartpuller2.order.OrderStatus;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RiderOrderRedactedDto {
    @Id
    @MongoId
    private String id;

    private OrderStatus orderStatus; // enum

}
