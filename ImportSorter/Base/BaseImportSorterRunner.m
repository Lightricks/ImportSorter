//
//  BaseImportSorterRunner.m
//  ImportSorter
//
//  Created by jun.hashimoto on 2015/08/02.
//  Copyright (c) 2015年 Jun Hashimoto. All rights reserved.
//

#import "BaseImportSorterRunner.h"

@implementation BaseImportSorterRunner

- (NSArray *)exportImportDeclarations
{
    NSString *sourceString = _sourceCodeView.textStorage.string;
    NSRange range = NSMakeRange(0, sourceString.length);

    NSMutableArray *importDeclarationsArray = [NSMutableArray array];
    while (range.length > 0) {
        NSRange subRange = [sourceString lineRangeForRange:NSMakeRange(range.location, 0)];

        NSString *line = [sourceString substringWithRange:subRange];
        if ([line hasPrefix:_importDeclarationPrefix]) {
            [importDeclarationsArray addObject:line];
        }

        range.location = NSMaxRange(subRange);
        range.length -= subRange.length;
    }

    return [importDeclarationsArray copy];
}

- (void)insertSortedImportDeclaration:(NSString *)importDeclarations
{
    NSRange replacementRange = [self getReplacementRange];
    [_sourceCodeView insertText:importDeclarations replacementRange:replacementRange];
}

- (NSRange)getReplacementRange
{
  NSRange range = [self getRangeStartingFromLastLineInPrefix];

  NSInteger replaceBeginLocation = range.location;
  NSInteger replaceEndLocation = [self getLastLineLocationInImports:range];

  NSInteger replaceLength = MAX(replaceEndLocation - replaceBeginLocation, 0);
  return NSMakeRange(replaceBeginLocation, replaceLength);
}

- (NSRange)getRangeStartingFromLastLineInPrefix
{
  NSString *sourceString = _sourceCodeView.textStorage.string;
  NSRange range = NSMakeRange(0, sourceString.length);

  NSRange subRange = [sourceString lineRangeForRange:NSMakeRange(range.location, 0)];
  NSString *line = [sourceString substringWithRange:subRange];

  while (![line hasPrefix:@"//"]) {
    range = [self getRangeStartingFromNextLine:range currentLine:subRange];

    subRange = [sourceString lineRangeForRange:NSMakeRange(range.location, 0)];
    line = [sourceString substringWithRange:subRange];
  }

  while ([line hasPrefix:@"//"]) {
    range = [self getRangeStartingFromNextLine:range currentLine:subRange];

    subRange = [sourceString lineRangeForRange:NSMakeRange(range.location, 0)];
    line = [sourceString substringWithRange:subRange];
  }

  return range;
}

- (NSInteger)getLastLineLocationInImports:(NSRange)firstLine
{
  NSInteger lastLineLocation = 0;

  NSRange range = firstLine;
  NSString *sourceString = _sourceCodeView.textStorage.string;
  NSRange subRange = [sourceString lineRangeForRange:NSMakeRange(range.location, 0)];
  NSString *line = [sourceString substringWithRange:subRange];

  while (range.length > 0) {
    subRange = [sourceString lineRangeForRange:NSMakeRange(range.location, 0)];
    line = [sourceString substringWithRange:subRange];

    if ([line hasPrefix:_importDeclarationPrefix]) {
      lastLineLocation = NSMaxRange(subRange);
    }
    range = [self getRangeStartingFromNextLine:range currentLine:subRange];
  }

  return lastLineLocation;
}

- (NSRange)getRangeStartingFromNextLine:(NSRange)currentRange currentLine:(NSRange)currentLine
{
  return NSMakeRange(NSMaxRange(currentLine), currentRange.length - currentLine.length);
}

@end
