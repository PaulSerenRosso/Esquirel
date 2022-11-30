using Entities.Capacities;
using UnityEngine;

public class GlobalDelegates : MonoBehaviour
{
    public delegate void NoParameterDelegate();

    public delegate void OneParameterDelegate<P>(P parameter);

    public delegate void TwoParameterDelegate<P1, P2>(P1 firstParameter, P2 secondParameter);

    public delegate void ThirdParameterDelegate<P1, P2, P3>(P1 firstParameter, P2 secondParameter, P3 thirdParameter);

    public  delegate void FourthParameterDelegate<P1, P2, P3, P4>(P1 firstParameter, P2 secondParameter,
        P3 thirdParameter, P4 fourthParameter);

   // public delegate void ByteIntArrayVector3ArrayDelegate(byte b, int[] uintArray, Vector3[] vector3s);

  //  public delegate void ByteIntArrayVector3ArrayCapacityDelegate(byte b, int[] uintArray, Vector3[] vector3s,
    //    ActiveCapacity capacity);

 // public delegate void ByteIntArrayVector3ArrayBoolArrayDelegate(byte b, int[] uintArray, Vector3[] vector3s,
   //   bool[] bools);
}