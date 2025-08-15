from typing import Optional, Dict, Any, List
from pydantic import BaseModel


class SolveRequest(BaseModel):
    id: str
    image_path: str
    prompt: Optional[str] = None
    user_id: Optional[str] = None
    results: Optional[List["SolveResult"]] = None
    error: Optional[str] = None


class SolveResult(BaseModel):
    solution: Optional[str] = None
    final_result: Optional[str] = None
    error: Optional[str] = None


{'request_id': 'a2f0f780-230e-4aa4-a492-fa42be682117', 
 'results': [
     {'solution': "To convert the number 'sixty-three thousand and forty' into numerals, we need to break it down by place value. Sixty-three thousand means $63 \\times 1000 = 63000$. The word 'and' typically signifies the start of the part after the thousands, and 'forty' represents $40$. Combining these parts, we add them together. So, we have $63000 + 40$.", 
      'final_result': '63040', 
      'error': None}, 
     {'solution': "The problem states that the figure is made up of 20 identical small rectangles. To find the percentage of the figure that is shaded, we need to count the number of shaded rectangles and then divide that by the total number of rectangles, multiplying the result by 100 to convert it to a percentage. First, let's count the shaded rectangles. From the image, we can see there are 3 shaded rectangles in the top row and 1 shaded rectangle in the bottom row. So, the total number of shaded rectangles is $3 + 1 = 4$. The total number of rectangles is given as 20. Now, we can calculate the fraction of the figure that is shaded: $\\text{Fraction shaded} = \\frac{\\text{Number of shaded rectangles}}{\\text{Total number of rectangles}} = \\frac{4}{20}$. To convert this fraction to a percentage, we multiply by 100%: $\\text{Percentage shaded} = \\frac{4}{20} \\times 100\\%$. We can simplify the fraction $\\frac{4}{20}$ to $\\frac{1}{5}$. So, $\\text{Percentage shaded} = \\frac{1}{5} \\times 100\\%$.", 'final_result': '20%', 'error': None}]}