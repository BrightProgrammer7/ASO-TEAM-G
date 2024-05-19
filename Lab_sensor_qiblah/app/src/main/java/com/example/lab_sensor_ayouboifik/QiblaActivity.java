package com.example.lab_sensor_ayouboifik;

import androidx.appcompat.app.AppCompatActivity;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.widget.TextView;

public class QiblaActivity extends AppCompatActivity {

    private SensorManager sensorManager;
    private Sensor sensorAccelerometer;
    private Sensor sensorMagneticField;
    private float[] floatGravity = new float[3];
    private float[] floatGeoMagnetic = new float[3];
    private float[] floatOrientation = new float[3];
    private float[] floatRotationMatrix = new float[9];
    private TextView qiblaDirection;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qibla);

        qiblaDirection = findViewById(R.id.qiblaDirection);
        sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        sensorAccelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        sensorMagneticField = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);

        SensorEventListener sensorEventListener = new SensorEventListener() {
            @Override
            public void onSensorChanged(SensorEvent event) {
                if (event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
                    floatGravity = event.values.clone();
                } else if (event.sensor.getType() == Sensor.TYPE_MAGNETIC_FIELD) {
                    floatGeoMagnetic = event.values.clone();
                }

                SensorManager.getRotationMatrix(floatRotationMatrix, null, floatGravity, floatGeoMagnetic);
                SensorManager.getOrientation(floatRotationMatrix, floatOrientation);
                float azimuth = (float) Math.toDegrees(floatOrientation[0]);
                float qiblaAngle = calculateQiblaAngle();
                float qiblaDirectionInDegrees = azimuth + qiblaAngle;
                qiblaDirection.setText("Qibla Direction: " + qiblaDirectionInDegrees + "°");
            }

            @Override
            public void onAccuracyChanged(Sensor sensor, int accuracy) {
            }
        };

        sensorManager.registerListener(sensorEventListener, sensorAccelerometer, SensorManager.SENSOR_DELAY_NORMAL);
        sensorManager.registerListener(sensorEventListener, sensorMagneticField, SensorManager.SENSOR_DELAY_NORMAL);
    }

    private float calculateQiblaAngle() {
        // Remplacez par la logique réelle pour calculer l'angle de la Qibla en fonction de votre position
        return 45.0f; // Exemple fixe pour l'angle de la Qibla
    }
}
