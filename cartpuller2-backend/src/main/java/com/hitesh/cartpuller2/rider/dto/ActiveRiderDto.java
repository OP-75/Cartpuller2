package com.hitesh.cartpuller2.rider.dto;

import java.io.Serializable;
import java.util.Date;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.MongoId;
import lombok.Data;

@Data
// implements Serializable for caching
public class ActiveRiderDto implements Serializable {

    @Id
    @MongoId
    private String id;

    final private String email;

    private Date startedOn;
    private String name;
    private String phoneNumber;
    private String Address;
    private String longitude;
    private String latitude;

}
