using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UpdateFloorVisual : MonoBehaviour {
    [SerializeField] private Material mat = null;
    [SerializeField] private float startValue = 0;
    [SerializeField] private float speedValue = 1;
    [SerializeField] private float minValue = -1;
    [SerializeField] private float maxValue = 1;
    private float value = 0;
    private bool capture = false;

    private void Start() {
        value = startValue;
        mat.SetFloat("_SliderColor", value);
    }

    private void Update() {
        if(!capture) return;
        value -= Time.deltaTime * speedValue;
        value = Mathf.Clamp(value, minValue, maxValue);
        mat.SetFloat("_SliderColor", value);
    }

    public void StartCapture(){
        value = startValue;
	    capture = true;
    }
}
