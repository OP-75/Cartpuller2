package com.hitesh.cartpuller2.service;

import java.util.Map;

import org.springframework.security.core.userdetails.UserDetails;

public interface JwtService {
    public String genrateTokenMethod(UserDetails userDetails);

    public String extractUserName(String token);

    public boolean isTokenValid(String token, UserDetails userDetails);

    public String genrateRefreshTokenMethod(Map<String, Object> extraClaims, UserDetails userDetails);
}
