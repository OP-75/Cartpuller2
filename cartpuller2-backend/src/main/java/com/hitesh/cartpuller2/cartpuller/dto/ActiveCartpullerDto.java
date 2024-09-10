package com.hitesh.cartpuller2.cartpuller.dto;

import java.io.Serializable;
import java.util.Date;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.MongoId;
import lombok.Data;

@Data
// implements Serializable for caching
public class ActiveCartpullerDto implements Serializable {
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
