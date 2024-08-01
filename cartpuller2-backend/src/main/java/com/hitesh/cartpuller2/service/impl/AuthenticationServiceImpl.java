package com.hitesh.cartpuller2.service.impl;

import java.util.HashMap;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.hitesh.cartpuller2.service.AuthenticationService;
import com.hitesh.cartpuller2.service.JwtService;
import com.hitesh.cartpuller2.user.User;
import com.hitesh.cartpuller2.user.UserRepository;
import com.hitesh.cartpuller2.user.dto.JwtAuthenticationResponse;
import com.hitesh.cartpuller2.user.dto.LoginRequest;
import com.hitesh.cartpuller2.user.dto.RefreshTokenRequest;
import com.hitesh.cartpuller2.user.dto.SignUpRequest;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AuthenticationServiceImpl implements AuthenticationService {

    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;

    public User signUp(SignUpRequest signUpRequest) {
        User user = new User(signUpRequest.getEmail());

        user.setHashedPassword(passwordEncoder.encode(signUpRequest.getPassword()));
        user.setName(signUpRequest.getName());
        user.setPhoneNumber(signUpRequest.getPhoneNumber());
        user.setAddress(signUpRequest.getAddress());
        user.setLongitude(signUpRequest.getLongitude());
        user.setLatitude(signUpRequest.getLatitude());

        userRepository.save(user);

        return user;

    }

    public JwtAuthenticationResponse login(LoginRequest loginRequest) {

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getEmail(), loginRequest.getPassword()));

        String email = loginRequest.getEmail();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User with email:" + email + " not found"));

        String jwt = jwtService.genrateTokenMethod(user);
        String refreshToken = jwtService.genrateRefreshTokenMethod(new HashMap<>(), user);

        return new JwtAuthenticationResponse(jwt, refreshToken);
    }

    public JwtAuthenticationResponse refreshToken(RefreshTokenRequest refreshTokenRequest) {
        String userEmail = jwtService.extractUserName(refreshTokenRequest.getRefreshToken());

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User with email:" + userEmail + " not found"));

        if (jwtService.isTokenValid(refreshTokenRequest.getRefreshToken(), user)) {
            String jwt = jwtService.genrateTokenMethod(user);

            return new JwtAuthenticationResponse(jwt, refreshTokenRequest.getRefreshToken());
        }
        return null;
    }

}
