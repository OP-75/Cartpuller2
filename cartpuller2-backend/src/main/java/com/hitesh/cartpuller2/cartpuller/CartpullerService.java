package com.hitesh.cartpuller2.cartpuller;

import java.util.Date;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.hitesh.cartpuller2.cartpuller.dto.Location;
import com.hitesh.cartpuller2.cartpuller.exception.CartpullerNotActivatedException;
import com.hitesh.cartpuller2.service.HelperService;
import com.hitesh.cartpuller2.user.User;
import com.hitesh.cartpuller2.user.service.UserService;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class CartpullerService {

    private final UserService userService;
    private final HelperService helperService;
    private final ActiveCartpullerRepository activeCartpullerRepository;

    public void activateCartpuller(Location location, HttpServletRequest request) {

        final String email = helperService.getEmailFromRequest(request);

        Optional<ActiveCartpuller> optionalCartpuller = activeCartpullerRepository.findByEmail(email);
        if (optionalCartpuller.isPresent()) {
            // if cartpuller alredy in table delete old one and set new one
            ActiveCartpuller oldCartpuller = optionalCartpuller.get();
            activeCartpullerRepository.delete(oldCartpuller);

            oldCartpuller.setStartedOn(new Date());
            ActiveCartpuller newCartpuller = oldCartpuller;
            activeCartpullerRepository.insert(newCartpuller);

            return;
        }

        final User user = userService.getUserByEmail(email);

        ActiveCartpuller cartpuller = new ActiveCartpuller(email,
                new Date(),
                user.getName(),
                user.getPhoneNumber(),
                user.getAddress(),
                location.getLongitude(),
                location.getLatitude());

        activeCartpullerRepository.save(cartpuller);

    }

    public void deactivateCartpuller(HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        Optional<ActiveCartpuller> optionalCartpuller = activeCartpullerRepository.findByEmail(email);
        if (optionalCartpuller.isPresent()) {
            activeCartpullerRepository.delete(optionalCartpuller.get());
        }
    }

    public void updateCartpullerLocation(Location location, HttpServletRequest request) {

        final String email = helperService.getEmailFromRequest(request);

        Optional<ActiveCartpuller> optionalCartpuller = activeCartpullerRepository.findByEmail(email);
        if (optionalCartpuller.isPresent()) {
            // get old cartpuller and delete it, then save new cart puller with location
            ActiveCartpuller oldCartpuller = optionalCartpuller.get();
            activeCartpullerRepository.delete(oldCartpuller);

            oldCartpuller.setLongitude(location.getLongitude());
            oldCartpuller.setLatitude(location.getLatitude());
            ActiveCartpuller newCartpuller = oldCartpuller;
            activeCartpullerRepository.insert(newCartpuller);

            return;
        } else {
            throw new CartpullerNotActivatedException("Cartpuller is inactive");
        }
    }

}
