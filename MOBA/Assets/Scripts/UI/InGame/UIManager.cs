using System;
using UnityEngine;
using UnityEngine.UI;

public partial class UIManager : MonoBehaviour
{
    public static UIManager Instance;

    [SerializeField]
    private RectTransform cursor;
    [SerializeField]
    private Image cursorImage;
    [SerializeField]
    private Sprite aimCursorSprite;
    [SerializeField]
    private Sprite baseCursorSprite; 
    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            DestroyImmediate(gameObject);
            return;
        }

        Instance = this;
    }

    private void Update()
    {
        cursor.position =Input.mousePosition;
    }

    public void ChangeCursorSpriteToAimSprite()
    {
        cursorImage.sprite = aimCursorSprite; 
    }
    
    public void ChangeCursorSpriteToBaseSprite()
    {
        cursorImage.sprite = baseCursorSprite;
    }

    public void ChangeCursorSpriteColor(Color color)
    {
        cursorImage.color = color;
    }
    

    public void LookAtCamera(Transform transform)
    {
        transform.LookAt(transform.position + Camera.main.transform.rotation * Vector3.forward, Camera.main.transform.rotation * Vector3.up);
    }
}