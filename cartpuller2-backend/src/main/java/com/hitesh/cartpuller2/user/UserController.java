package com.hitesh.cartpuller2.user;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.hitesh.cartpuller2.service.AuthenticationService;
import com.hitesh.cartpuller2.user.dto.JwtAuthenticationResponse;
import com.hitesh.cartpuller2.user.dto.LoginRequest;
import com.hitesh.cartpuller2.user.dto.RefreshTokenRequest;
import com.hitesh.cartpuller2.user.dto.SignUpRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@RestController
@RequiredArgsConstructor // constructor for dependency injection
@RequestMapping("/api/user")
public class UserController {

    private final AuthenticationService authenticationService;

    @PostMapping("/auth/signup")
    public ResponseEntity<User> signUp(@RequestBody SignUpRequest signUpRequest) {
        // TODO: Add Role here before passing when role based auth is done

        return ResponseEntity.ok(authenticationService.signUp(signUpRequest));
    }

    @PostMapping("/auth/login")
    public ResponseEntity<JwtAuthenticationResponse> login(@RequestBody LoginRequest loginRequest) {

        return ResponseEntity.ok(authenticationService.login(loginRequest));
    }

    @PostMapping("/auth/refresh-token")
    public ResponseEntity<JwtAuthenticationResponse> refreshToken(
            @RequestBody RefreshTokenRequest refreshTokenRequest) {

        return ResponseEntity.ok(authenticationService.refreshToken(refreshTokenRequest));
    }

}
