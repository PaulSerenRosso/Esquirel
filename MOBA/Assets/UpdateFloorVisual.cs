using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UpdateFloorVisual : MonoBehaviour {
    [SerializeField] private Material mat = null;
    [SerializeField] private float value = 0;
    [SerializeField] private float speedValue = 1;
    private bool capture = false;
    private void Start() => mat.SetFloat("_SliderColor", value);

    private void Update() {
        if(!capture) return;
        value -= Time.deltaTime * speedValue;
        value = Mathf.Clamp(value, -1, 1);
        mat.SetFloat("_SliderColor", value);
    }

    public void StartCapture() => capture = true;
}
