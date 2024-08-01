package com.hitesh.cartpuller2.service;

import com.hitesh.cartpuller2.user.User;
import com.hitesh.cartpuller2.user.dto.JwtAuthenticationResponse;
import com.hitesh.cartpuller2.user.dto.LoginRequest;
import com.hitesh.cartpuller2.user.dto.RefreshTokenRequest;
import com.hitesh.cartpuller2.user.dto.SignUpRequest;

public interface AuthenticationService {
    public User signUp(SignUpRequest signUpRequest);

    public JwtAuthenticationResponse login(LoginRequest loginRequest);

    public JwtAuthenticationResponse refreshToken(RefreshTokenRequest refreshTokenRequest);
}
