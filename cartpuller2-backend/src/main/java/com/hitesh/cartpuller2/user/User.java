package com.hitesh.cartpuller2.user;

import java.io.Serializable;
import java.util.Collection;
import java.util.List;

import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.MongoId;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import lombok.Data;

@SuppressWarnings("unused")
@Data
@Document(collection = "Users")
public class User implements Serializable, UserDetails {
    // implement Serializable for redis caching

    // TODO: need to have roles for customer, rider, seller

    @MongoId
    String id;

    final String email;
    String hashedPassword;
    String name;
    String phoneNumber;
    String Address;
    String longitude;
    String latitude;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of();
    }

    @Override
    public String getPassword() {
        return this.hashedPassword;
    }

    @Override
    public String getUsername() {
        return this.email;
    }
}
