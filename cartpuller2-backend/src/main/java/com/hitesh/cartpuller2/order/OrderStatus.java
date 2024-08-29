package com.hitesh.cartpuller2.order;

public enum OrderStatus {

    SENT,
    ACCEPTED, // Accepted means accepted by cartpuller
    RIDER_ASSIGNED, // rider is assigned but order is not picked up by rider
    DELIVERY_IN_PROGRESS, // rider has picked up order from cartpuller ie cartpuller has no involvement in
                          // fulling the order now
    DELIVERED

}
