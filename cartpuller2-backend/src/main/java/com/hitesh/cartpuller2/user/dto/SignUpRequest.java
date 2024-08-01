package com.hitesh.cartpuller2.user.dto;

import lombok.Data;

@Data
public class SignUpRequest {

    String email;
    String password;
    String name;
    String phoneNumber;
    String Address;
    String longitude;
    String latitude;

}
