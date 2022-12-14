using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CursorManager : MonoBehaviour
{   
    
    public static CursorManager Instance;

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
        Cursor.visible = false;
        Cursor.lockState =CursorLockMode.None;
     
        DontDestroyOnLoad(this);
        
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
}
