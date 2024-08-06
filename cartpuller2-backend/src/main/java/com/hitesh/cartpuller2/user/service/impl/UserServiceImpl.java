package com.hitesh.cartpuller2.user.service.impl;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.hitesh.cartpuller2.user.UserRepository;
import com.hitesh.cartpuller2.user.UserService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    // shouldnt cache this
    public UserDetails getUserByEmail(String email) {

        return userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User with email:" + email + " not found"));

    }

}
