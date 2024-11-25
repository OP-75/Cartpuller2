package com.hitesh.cartpuller2.vegetable;

import java.io.Serializable;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data // ! Imp! You have to put this annotation so that spring can return a valid non-
      // empty json (it creates all the getter, constructor, etc, read more online)
      // getters are needed to convert this obj into json
@AllArgsConstructor
@Document(collection = "Vegetables")
public class Vegetable implements Serializable {
    // implement serializable so that we can seralize and store in redis

    @Id // ! overloaded method since I have manually created vegetables in mongodb we
    // ! have to find them by ObjectId instead of String id
    String id;
    final String title;
    final int price;

}
