import { json } from '@sveltejs/kit';
import { unlink } from 'fs/promises';

export async function POST({ request, cookies }) {
    try {
        // Get the raw binary data from the request
        const arrayBuffer = await request.arrayBuffer();
        const data = new Uint8ClampedArray(arrayBuffer);

        // Since ImageData includes RGBA values (4 values per pixel),
        // we need to extract just the grayscale values (first of every 4 values)
        const grayscaleValues = [];
        for (let i = 0; i < data.length; i += 4) {
            grayscaleValues.push(data[i]);
        }

        // Convert to normalized values [0,1]
        const normalizedData = grayscaleValues.map((x) => x / 255.0).join(',');

        // Create a Python script that loads and runs the model
        const pythonScript = `
import numpy as np
import tensorflow as tf
from tensorflow import keras

# Suppress TensorFlow logging
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

# Load the model weights
model = keras.models.load_model('../models/handwriting_model.keras')

# Get the input data and reshape it to match model input shape (1, 28, 28, 1)
input_data = np.array([float(x) for x in '${normalizedData}'.split(',')])
input_data = input_data.reshape(1, 28, 28, 1)

# Make prediction
prediction = model.predict(input_data)
result = prediction.argmax()

# Print the result so we can capture it
print(result)
        `;

        // Save the Python script to a temporary file
        await Bun.write('temp_predict.py', pythonScript);

        // Run the Python script using Bun.spawn
        const proc = Bun.spawn(['../.venv/bin/python3', 'temp_predict.py']);

        const output = await new Response(proc.stdout).text();

        console.log(output.slice(-2));

        // Clean up the temporary file
        await unlink('temp_predict.py');

        // Parse the prediction from the output
        const prediction = parseInt(output.slice(-2));

        console.log(prediction);

        // Return the prediction as JSON
        return json({ prediction });
    } catch (error) {
        console.error('Prediction error:', error);
        return json({ error: 'Failed to process image' }, { status: 500 });
    }
}
