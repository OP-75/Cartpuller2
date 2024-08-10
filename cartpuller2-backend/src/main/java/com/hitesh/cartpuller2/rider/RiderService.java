package com.hitesh.cartpuller2.rider;

import java.util.Date;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.hitesh.cartpuller2.global.dto.Activity;
import com.hitesh.cartpuller2.global.dto.Location;
import com.hitesh.cartpuller2.order.OrderService;
import com.hitesh.cartpuller2.rider.exception.RiderInactiveException;
import com.hitesh.cartpuller2.service.HelperService;
import com.hitesh.cartpuller2.user.User;
import com.hitesh.cartpuller2.user.service.UserService;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class RiderService {

    private final UserService userService;
    private final OrderService orderService;
    private final HelperService helperService;
    private final ActiveRiderRepository activeRiderRepository;

    public void activateRider(Location location, HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        Optional<ActiveRider> optionalRider = activeRiderRepository.findByEmail(email);
        if (optionalRider.isPresent()) {
            // if rider alredy in table delete old one and set new one
            ActiveRider oldRider = optionalRider.get();
            activeRiderRepository.delete(oldRider);

            oldRider.setStartedOn(new Date());
            ActiveRider newRider = oldRider;
            activeRiderRepository.insert(newRider);

            return;
        }

        final User user = userService.getUserByEmail(email);

        ActiveRider cartpuller = new ActiveRider(email,
                new Date(),
                user.getName(),
                user.getPhoneNumber(),
                user.getAddress(),
                location.getLongitude(),
                location.getLatitude());

        activeRiderRepository.save(cartpuller);

    }

    public void deactivateRider(HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        Optional<ActiveRider> optionalRider = activeRiderRepository.findByEmail(email);
        if (optionalRider.isPresent()) {
            activeRiderRepository.delete(optionalRider.get());
        }
    }

    public void updateRiderLocation(Location location, HttpServletRequest request) {
        final String email = helperService.getEmailFromRequest(request);

        Optional<ActiveRider> optionalCartpuller = activeRiderRepository.findByEmail(email);
        if (optionalCartpuller.isPresent()) {
            // get old cartpuller and delete it, then save new cart puller with location
            ActiveRider oldRider = optionalCartpuller.get();
            activeRiderRepository.delete(oldRider);

            oldRider.setLongitude(location.getLongitude());
            oldRider.setLatitude(location.getLatitude());
            ActiveRider newCartpuller = oldRider;
            activeRiderRepository.insert(newCartpuller);

            return;
        } else {
            throw new RiderInactiveException("Rider is inactive");
        }
    }

    public Activity checkActive(HttpServletRequest request) {
        String email = helperService.getEmailFromRequest(request);
        if (activeRiderRepository.findByEmail(email).isPresent()) {
            return new Activity(true);
        } else {
            return new Activity(false);
        }
    }

}
