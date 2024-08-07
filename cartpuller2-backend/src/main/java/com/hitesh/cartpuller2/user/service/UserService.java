package com.hitesh.cartpuller2.user.service;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.hitesh.cartpuller2.user.User;
import com.hitesh.cartpuller2.user.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    // shouldnt cache this
    public UserDetails getUserDetailsByEmail(String email) {

        return userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User with email:" + email + " not found"));

    }

    // shouldnt cache this
    public User getUserByEmail(String email) {

        return userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User with email:" + email + " not found"));

    }

}
