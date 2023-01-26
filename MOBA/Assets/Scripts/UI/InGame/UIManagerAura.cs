using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public partial class UIManager
{
    public void SetUpAuraSprite(int auraValue, AuraUIImage auraUIImage, GlobalDelegates.NoParameterDelegate capacity)
    {
        playerInterface.SetUpAuraSprite(auraValue,  auraUIImage, capacity);
    }

    public void UpdateAuraCapacityRank(int auraValue, AuraUIImage auraUIImage)
    {
        playerInterface.UpdateAuraValue(auraValue, auraUIImage);
    }

    public void UpdateAuraValue(int value)
    {
        playerInterface.UpdateNumberOfAuraAvailable(value);
    }

    public void ChangeAuraState(bool isActiv) => playerInterface.ChangeAuraState(isActiv);
}
