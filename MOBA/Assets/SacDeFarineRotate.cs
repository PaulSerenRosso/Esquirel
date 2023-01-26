using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SacDeFarineRotate : MonoBehaviour
{
    [SerializeField] private float speed;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    public void OnUpdate()
    {
        transform.Rotate (speed*Time.deltaTime,speed*Time.deltaTime, speed*Time.deltaTime); //rotates 50 degrees per second around z axis
    }
}
