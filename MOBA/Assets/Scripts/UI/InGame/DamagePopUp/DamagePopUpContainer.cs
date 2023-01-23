using System;
using TMPro;
using UnityEngine;
using Random = UnityEngine.Random;

public class DamagePopUpContainer : MonoBehaviour {
    [SerializeField] private TextMeshProUGUI damageValueTxt = null;
    [SerializeField] private float speed = 0.05f;
    private Vector3 dir = new Vector3();
    
    /// <summary>
    /// Initialize the text value
    /// </summary>
    /// <param name="damage"></param>
    public void Init(int damage) {
        damageValueTxt.text = Mathf.Abs(damage).ToString();
        dir = new Vector3(Random.Range(-10, 11) / 10f, Random.Range(-10, 11) / 10f, 0);
    }

    private void Update() {
        transform.localPosition += dir * speed;
    }

    /// <summary>
    /// Destroy the object after .5sec
    /// </summary>
    public void DestroyObject() => Destroy(gameObject, .5f);
}