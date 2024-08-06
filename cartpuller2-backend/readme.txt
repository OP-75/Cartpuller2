All users ie customers, cartpullers, riders, get saved in one collection (caz of complexity of spring idk how to authenticate using diffrent tables in authentication manager
`authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(loginRequest.getEmail(), loginRequest.getPassword()));`
 so now we have role based auth)