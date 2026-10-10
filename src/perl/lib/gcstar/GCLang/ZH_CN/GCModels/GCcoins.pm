{
    package GCLang::ZH_CN::GCModels::GCcoins;

    use utf8;
###################################################
#
#  Copyright 2005-2007 Tian
#
#  This file is part of GCstar.
#
#  GCstar is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  GCstar is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with GCstar; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
###################################################
    
    use strict;
    use base 'Exporter';

    our @EXPORT = qw(%lang);

    our %lang = (
    
        CollectionDescription => '钱币收藏',
        Items => {0 => '份钱币',
                  1 => '份钱币',
                  X => '钱币'},
        NewItem => '新钱币',

        Name => '名称',
        Country => '国家',
        Year => '年份',
        Calendar => 'Calendar',
        Currency => '货币',
        Value => '价值',
        Picture => '主要图片',
        Diameter => '直径',
        Metal => '金属',
        Weight => 'Weight (g)',
        Depth => 'Depth (mm)',
        Edge => '边缘',
        Edge1 => '边缘1',
        Edge2 => '边缘2',
        Edge3 => '边缘3',
        Edge4 => '边缘4',
        Head => '正面（人頭）',
        Tail => '反面',
        Front => 'Front',
        Back => 'Back',
        Comments => '评论',
        History => '历史',
        Website => '网站',
        Estimate => '估价',
        References => '参考资料',
        Type => '类型',
        Coin => '硬币',
        Banknote => '钞票',

        "Anniversary coin" => 'Anniversary coin',
        "Non circulating coin" => 'Non circulating coin',
        Token => 'Token',
        
        Main => '主要',
        Description => '描述',
        Other => '其他信息',
        Pictures => '图片',
        
        Condition => 'PCGS状态分级',
        Grade1  => 'BS-1',
        Grade2  => 'FR-2',
        Grade3  => 'AG-3',
        Grade4  => 'G-4',
        Grade6  => 'G-6',
        Grade8  => 'VG-8',
        Grade10 => 'VG-10',
        Grade12 => 'F-12',
        Grade15 => 'F-15',
        Grade20 => 'VF-20',
        Grade25 => 'VF-25',
        Grade30 => 'VF-30',
        Grade35 => 'VF-35',
        Grade40 => 'XF-40',
        Grade45 => 'XF-45',
        Grade50 => 'AU-50',
        Grade53 => 'AU-53',
        Grade55 => 'AU-55',
        Grade58 => 'AU-58',
        Grade60 => 'MS-60',
        Grade61 => 'MS-61',
        Grade62 => 'MS-62',
        Grade63 => 'MS-63',
        Grade64 => 'MS-64',
        Grade65 => 'MS-65',
        Grade66 => 'MS-66',
        Grade67 => 'MS-67',
        Grade68 => 'MS-68',
        Grade69 => 'MS-69',
        Grade70 => 'MS-70',
    
        Axis => 'Axis',
        Medal => 'Medal',
        Monetary => 'Monetary (180º)',
        Turn => 'Turn',
        "Years of coinage" => 'Years of coinage',
        Quantity => 'Quantity',
        Mint => 'Mint',
        "Mint mark" => 'Mint mark',
        Mintmaster => 'Mintmaster',
        "Mintmaster mark" => 'Mintmaster mark',
        City => 'City',
        "City letter" => 'City letter',
        Series => 'Series',
        "Edge type" => 'Edge type',
        Catalogue1 => 'Catalogue1',
        Number1 => 'Number1',
        Catalogue2 => 'Catalogue2',
        Number2 => 'Number2',
        Number => 'Number',
        Form => 'Form',
        Buyed => 'Bought',
        Found => 'Found',
        Bring => 'Bring',
        Gift => 'Gift',
        Location => 'Location',
        Price => 'Price',
        
     );
}

1;
