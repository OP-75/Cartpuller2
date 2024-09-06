package com.hitesh.cartpuller2.cartpuller.dto;

import java.util.Date;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.MongoId;
import lombok.Data;

@Data
public class ActiveCartpullerDto {
    // ! This was made since location is now `GeoJsonPoint` but frontend app works
    // ! with `longitude` & `latitude` strings

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
