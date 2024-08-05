package com.hitesh.cartpuller2.service;

import org.springframework.stereotype.Service;

import io.micrometer.common.util.StringUtils;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class Helper {

    private final JwtService jwtService;

    public String getEmailFromRequest(HttpServletRequest request) {
        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String userEmail;

        if (StringUtils.isEmpty(authHeader) || !authHeader.startsWith("Bearer ")) {
            throw new IllegalAccessError("Cant find User email in header");
        }

        jwt = authHeader.substring(7);
        userEmail = jwtService.extractUserName(jwt);

        return userEmail;
    }

}
