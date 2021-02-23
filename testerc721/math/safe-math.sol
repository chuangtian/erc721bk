pragma solidity 0.5.6;

contract SafeMath
{

  /**
   * 两个数相乘，如果结果除以一个等于另一个抛出异常 
   * 返回两个数的和
   */
  function mul(uint256 _factor1, uint256 _factor2) public pure returns (uint256 product)
  {
    if (_factor1 == 0)
    {
      return 0;
    }
    product = _factor1 * _factor2;
    require(product / _factor1 == _factor2);
  }

  /**
   * 两个数相除，第二个参数不能为0.返回相除的结果，小数点后面的会忽略掉
   */
  function div( uint256 _dividend, uint256 _divisor) public pure returns (uint256 quotient)
  {
    require(_divisor > 0);
    quotient = _dividend / _divisor;
  }

  /**
   * 第一个减去第二个，第二参数必须小于第一个。返回相减的结果
   */
  function sub(uint256 _minuend, uint256 _subtrahend) public pure returns (uint256 difference)
  {
    require(_subtrahend <= _minuend);
    difference = _minuend - _subtrahend;
  }

  /**
   * @dev 两个参数相加,返回两个数的和
   */
  function add(uint256 _addend1, uint256 _addend2) public pure returns (uint256 sum)
  {
    sum = _addend1 + _addend2;
    require(sum >= _addend1);
  }

  /**
    *取余
    */
  function mod(uint256 _dividend, uint256 _divisor) public pure returns (uint256 remainder) 
  {
    require(_divisor != 0);
    remainder = _dividend % _divisor;
  }

}
