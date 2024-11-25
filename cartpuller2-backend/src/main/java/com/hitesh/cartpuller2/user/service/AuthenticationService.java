package com.hitesh.cartpuller2.user.service;

import java.util.HashMap;
import java.util.Set;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.hitesh.cartpuller2.service.JwtService;
import com.hitesh.cartpuller2.user.Role;
import com.hitesh.cartpuller2.user.User;
import com.hitesh.cartpuller2.user.UserRepository;
import com.hitesh.cartpuller2.user.dto.JwtAuthenticationResponse;
import com.hitesh.cartpuller2.user.dto.LoginRequest;
import com.hitesh.cartpuller2.user.dto.RefreshTokenRequest;
import com.hitesh.cartpuller2.user.dto.SignUpRequest;
import com.hitesh.cartpuller2.user.exception.UserAlreadyExistsException;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthenticationService {

    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;

    public User signUpCustomer(SignUpRequest signUpRequest) {

        signUpRequest.setEmail(signUpRequest.getEmail().toLowerCase().trim());

        if (userRepository.findByEmail(signUpRequest.getEmail()).isPresent()) {
            throw new UserAlreadyExistsException("User already exists");
        }

        User user = new User(signUpRequest.getEmail());

        user.setHashedPassword(passwordEncoder.encode(signUpRequest.getPassword()));
        user.setName(signUpRequest.getName());
        user.setPhoneNumber(signUpRequest.getPhoneNumber());
        user.setAddress(signUpRequest.getAddress());
        user.setLongitude(signUpRequest.getLongitude());
        user.setLatitude(signUpRequest.getLatitude());
        user.setRoles(Set.of(Role.CUSTOMER));

        userRepository.save(user);

        return user;

    }

    public User signUpCartpuller(SignUpRequest signUpRequest) {

        signUpRequest.setEmail(signUpRequest.getEmail().toLowerCase().trim());

        if (userRepository.findByEmail(signUpRequest.getEmail()).isPresent()) {
            throw new UserAlreadyExistsException("User already exists");
        }

        User user = new User(signUpRequest.getEmail());

        user.setHashedPassword(passwordEncoder.encode(signUpRequest.getPassword()));
        user.setName(signUpRequest.getName());
        user.setPhoneNumber(signUpRequest.getPhoneNumber());
        user.setAddress(signUpRequest.getAddress());
        user.setLongitude(signUpRequest.getLongitude());
        user.setLatitude(signUpRequest.getLatitude());
        user.setRoles(Set.of(Role.CARTPULLER));

        userRepository.save(user);

        return user;

    }

    public User signUpRider(SignUpRequest signUpRequest) {
        signUpRequest.setEmail(signUpRequest.getEmail().toLowerCase().trim());

        if (userRepository.findByEmail(signUpRequest.getEmail()).isPresent()) {
            throw new UserAlreadyExistsException("User already exists");
        }

        User user = new User(signUpRequest.getEmail());

        user.setHashedPassword(passwordEncoder.encode(signUpRequest.getPassword()));
        user.setName(signUpRequest.getName());
        user.setPhoneNumber(signUpRequest.getPhoneNumber());
        user.setAddress(signUpRequest.getAddress());
        user.setLongitude(signUpRequest.getLongitude());
        user.setLatitude(signUpRequest.getLatitude());
        user.setRoles(Set.of(Role.RIDER));

        userRepository.save(user);

        return user;
    }

    public JwtAuthenticationResponse login(LoginRequest loginRequest) {

        loginRequest.setEmail(loginRequest.getEmail().toLowerCase().trim());

        log.debug("Login request: " + loginRequest.toString());

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getEmail(), loginRequest.getPassword()));

        log.debug("Auth complete: " + loginRequest.toString());

        String email = loginRequest.getEmail();
        User user = userService.getUserByEmail(email);

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
