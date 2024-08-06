package com.hitesh.cartpuller2.cartpuller;

import java.io.Serializable;

import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.MongoId;

import lombok.Data;

@Data
@Document(collection = "Cartpullers")
public class Cartpuller implements Serializable {

    @MongoId
    private String id;

    private String email;
    private String hashedPassword;

    private String name;
    private String phoneNumber;
    private String Address;
    private String longitude;
    private String latitude;

}
