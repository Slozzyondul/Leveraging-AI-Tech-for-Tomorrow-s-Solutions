import tensorflow as tf

# Build a simple model
model = tf.keras.Sequential([
    tf.keras.layers.Dense(10, activation='relu', input_shape=(5,)),
    tf.keras.layers.Dense(1, activation='sigmoid')
])

# Save the mock model
model.save('pretrained_disaster_model.h5')
print("Mock model saved.")
