package com.hitesh.cartpuller2.rider;

import java.io.Serializable;
import java.util.Date;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.MongoId;

import com.mongodb.lang.NonNull;

import lombok.Data;

@Data
@Document(collection = "Active_Riders")
public class ActiveRider implements Serializable {

    @Id
    @MongoId
    private String id;

    final private String email;

    @NonNull
    private Date startedOn;
    @NonNull
    private String name;
    @NonNull
    private String phoneNumber;
    @NonNull
    private String Address;
    @NonNull
    private String longitude;
    @NonNull
    private String latitude;

}
