using System;
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
    private Sprite interactCursorSprite;
    [SerializeField]
    private Sprite aimCursorSprite;
    [SerializeField]
    private Sprite attackCursorSprite;
    [SerializeField]
    private Sprite baseCursorSprite;

    public  Enums.CursorType CurrentCursorType => currentCursorType;
    private Enums.CursorType currentCursorType;
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
        currentCursorType = Enums.CursorType.Aim;
        cursorImage.sprite = aimCursorSprite; 
    }
    public void ChangeCursorSpriteToInteractSprite()
    {
        currentCursorType = Enums.CursorType.Interact;
        cursorImage.sprite = interactCursorSprite; 
    }
    public void ChangeCursorSpriteToAttackSprite()
    {
        currentCursorType = Enums.CursorType.Attack;
        cursorImage.sprite = attackCursorSprite; 
    }
    
    public void ChangeCursorSpriteToBaseSprite()
    {
        currentCursorType = Enums.CursorType.Base;
        cursorImage.sprite = baseCursorSprite;
    }

    public void ChangeCursorSpriteColor(Color color)
    {
       
        cursorImage.color = color;
    }
}
