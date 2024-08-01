package com.hitesh.cartpuller2.user;

import org.springframework.security.core.userdetails.UserDetails;

public interface UserService {

    public UserDetails getUserByEmail(String email);
}
