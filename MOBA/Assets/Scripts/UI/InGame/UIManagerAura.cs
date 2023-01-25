using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public partial class UIManager
{
    public void SetUpAuraSprite(int auraValue, AuraUIImage auraUIImage, GlobalDelegates.NoParameterDelegate capacity)
    {
        playerInterface.SetUpAuraSprite(auraValue,  auraUIImage, capacity);
    }

    public void UpdateAuraValue(int auraValue, AuraUIImage auraUIImage)
    {
        playerInterface.UpdateAuraValue(auraValue, auraUIImage);
    }

    public void ChangeAuraState(bool isActiv) => playerInterface.ChangeAuraState(isActiv);
}
