using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public partial class UIManager
{
  [SerializeField]
  private TextMeshProUGUI goldText;

  public void UpdateGoldText(float value)
  {
    goldText.text = value.ToString();
  }
}
