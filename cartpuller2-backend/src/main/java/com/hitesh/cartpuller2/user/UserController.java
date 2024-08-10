package com.hitesh.cartpuller2.user;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.hitesh.cartpuller2.user.dto.JwtAuthenticationResponse;
import com.hitesh.cartpuller2.user.dto.LoginRequest;
import com.hitesh.cartpuller2.user.dto.RefreshTokenRequest;
import com.hitesh.cartpuller2.user.dto.SignUpRequest;
import com.hitesh.cartpuller2.user.service.AuthenticationService;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

//!this only does authentication work

@RestController
@RequiredArgsConstructor // constructor for dependency injection
@RequestMapping("/api/auth")
public class UserController {

    private final AuthenticationService authenticationService;

    @PostMapping("/signup-customer")
    public ResponseEntity<User> signUp(@RequestBody SignUpRequest signUpRequest) {
        User user = authenticationService.signUpCustomer(signUpRequest);
        user.setHashedPassword(null);
        return ResponseEntity.ok(user);
    }

    @PostMapping("/signup-cartpuller")
    public ResponseEntity<User> signUpCartpuller(@RequestBody SignUpRequest signUpRequest) {
        User user = authenticationService.signUpCartpuller(signUpRequest);
        user.setHashedPassword(null);
        return ResponseEntity.ok(user);
    }

    @PostMapping("/signup-rider")
    public ResponseEntity<User> signUpRider(@RequestBody SignUpRequest signUpRequest) {
        User user = authenticationService.signUpRider(signUpRequest);
        user.setHashedPassword(null);
        return ResponseEntity.ok(user);
    }

    @PostMapping("/login")
    public ResponseEntity<JwtAuthenticationResponse> login(@RequestBody LoginRequest loginRequest) {

        return ResponseEntity.ok(authenticationService.login(loginRequest));
    }

    @PostMapping("/auth/refresh-token")
    public ResponseEntity<JwtAuthenticationResponse> refreshToken(
            @RequestBody RefreshTokenRequest refreshTokenRequest) {

        return ResponseEntity.ok(authenticationService.refreshToken(refreshTokenRequest));
    }

    @GetMapping("/ping")
    public ResponseEntity<String> refreshToken() {

        return ResponseEntity.ok("pong");
    }

}
