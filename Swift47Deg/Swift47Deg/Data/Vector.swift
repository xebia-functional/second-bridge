//
//  Vector.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 22/4/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import Foundation

struct Vector<T> {
    
    typealias Array1 = [T]
    typealias Array2 = [[T]]
    typealias Array3 = [[[T]]]
    typealias Array4 = [[[[T]]]]
    typealias Array5 = [[[[[T]]]]]
    typealias Array6 = [[[[[[T]]]]]]
    typealias Array7 = [[[[[[[T]]]]]]]
    
    private var level1 : Array1?
    private var level2 : Array2?
    private var level3 : Array3?
    private var level4 : Array4?
    private var level5 : Array5?
    private var level6 : Array6?
    private var level7 : Array7?
    
    private var currentLevel : Int
    
    // MARK: - Initializers
    init() {
        // Empty vector:
        currentLevel = 0
    }
    
    private init(_ trie: Array1) {
        currentLevel = 1
        level1 = trie
    }
    
    private init(_ trie: Array2) {
        currentLevel = 2
        level2 = trie
    }
    
    private init(_ trie: Array3) {
        currentLevel = 3
        level3 = trie
    }
    
    private init(_ trie: Array4) {
        currentLevel = 4
        level4 = trie
    }
    
    private init(_ trie: Array5) {
        currentLevel = 5
        level5 = trie
    }
    
    private init(_ trie: Array6) {
        currentLevel = 6
        level6 = trie
    }
    
    private init(_ trie: Array7) {
        currentLevel = 7
        level7 = trie
    }
}

// MARK: - Level 0 operations

extension Vector {
    private func append0(tail: Array1) -> Vector {
        return Vector(tail)
    }
}

// MARK: - Level 1 operations

extension Vector {
    private func update1(trie: Array1, index: Int, obj: T) -> Vector {
        var trie2 = trie
        trie2[index & 0x01] = obj
        return Vector(trie2)
    }
    
    private func append1(trie: Array1, tail: Array1) -> Vector {
        var trie2 = Array2()
        trie2.append(trie)
        trie2.append(tail)
        return Vector(trie2)
    }
    
    private func pop1(trie: Array1) -> (Vector, Array1) {
        return (Vector(), trie)
    }
}

// MARK: - Level 2 operations

extension Vector {
    private func update2(trie: Array2, index: Int, obj: T) -> Vector {
        var trie2a = trie
        var trie2b = trie2a[(index >> 5) & 0x01]
        
        trie2a[(index >> 5) & 0x01] = trie2b
        trie2b[index & 0x01] = obj
        return Vector(trie2a)
    }
    
    private func append2(trie: Array2, tail: Array1) -> Vector {
        if trie.count >= 32 {
            var trie2 = Array3()
            trie2.append(trie)
            trie2.append(Array2())
            trie2[1].append(tail)
            return Vector(trie2)
        } else {
            var trie2 = trie
            trie2.append(tail)
            return Vector(trie2)
        }
    }
    
    private func pop2(trie: Array2) -> (Vector, Array1) {
        if trie.count == 2 {
            return (Vector(trie[0]), trie.last!)
        } else {
            var trie2 = trie
            trie2.removeLast()
            return (Vector(trie2), trie.last!)
        }
    }
}

// MARK: - Level 3 operations

extension Vector {
    private func update3(trie: Array3, index: Int, obj: T) -> Vector {
        var trie2a = trie
        var trie2b = trie2a[(index >> 10) & 0x01]
        
        trie2a[(index >> 10) & 0x01] = trie2b
        var trie2c = trie2b[(index >> 5) & 0x01]
        
        trie2b[(index >> 5) & 0x01] = trie2c
        trie2c[index & 0x01] = obj
        return Vector(trie2a)
    }
    
    private func append3(trie: Array3, tail: Array1) -> Vector {
        if trie.last!.count >= 32 {
            if trie.count >= 32 {
                var trie2 = Array4()
                
                trie2.append(trie)
                trie2.append(Array3())
                trie2[1].append(Array2())
                trie2[1][0].append(tail)
                
                return Vector(trie2)
            } else {
                var trie2 = trie
                var emptyTrie = Array2()
                emptyTrie.append(tail)
                trie2.append(emptyTrie)
                return Vector(trie2)
            }
        } else {
            var trie2 = trie
            var lastItem = trie2.last!
            lastItem.append(tail)
            trie2[trie2.count - 1] = lastItem
            return Vector(trie2)
        }
    }
    
    private func pop3(trie: Array3) -> (Vector, Array1) {
        if trie.last!.count == 1 {
            if trie.count == 2 {
                return (Vector(trie[0]), trie.last!.last!)
            } else {
                var trie2 = trie
                trie2.removeLast()
                return (Vector(trie2), trie.last!.last!)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            trie2Last.removeLast()
            trie2[trie2.count - 1] = trie2Last
            return (Vector(trie2), trie.last!.last!)
        }
    }
}

// MARK: - Level 4 operations

extension Vector {
    private func update4(trie: Array4, index: Int, obj: T) -> Vector {
        var trie2a = trie
        var trie2b = trie2a[(index >> 15) & 0x01]
        var trie2c = trie2b[(index >> 10) & 0x01]
        var trie2d = trie2c[(index >> 5) & 0x01]
        
        trie2d[index & 0x01] = obj
        trie2c[(index >> 5) & 0x01] = trie2d
        trie2b[(index >> 10) & 0x01] = trie2c
        trie2a[(index >> 15) & 0x01] = trie2b
        return Vector(trie2a)
    }
    
    private func append4(trie: Array4, tail: Array1) -> Vector {
        if trie.last!.last!.count >= 32 {
            if trie.last!.count >= 32 {
                if trie.count >= 32 {
                    var trie2 = Array5()
                    trie2.append(trie)
                    trie2.append(Array4())
                    
                    trie2[1].append(Array3())
                    trie2[1][0].append(Array2())
                    trie2[1][0][0].append(tail)
                    
                    return Vector(trie2)
                } else {
                    var trie2 = trie
                    trie2.append(Array3())
                    
                    var trie2Last = trie2.last!
                    trie2Last.append(Array2())
                    
                    var trie2LastLast = trie2Last.last!
                    trie2LastLast.append(tail)
                    
                    trie2Last[trie2Last.count - 1] = trie2LastLast
                    trie2[trie2.count - 1] = trie2Last
                    
                    return Vector(trie2)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                trie2Last.append(Array2())
                
                var trie2LastLast = trie2Last.last!
                trie2LastLast.append(tail)
                
                trie2Last[trie2Last.count - 1] = trie2LastLast
                trie2[trie2.count - 1] = trie2Last
                
                return Vector(trie2)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            var trie2LastLast = trie2Last.last!
            trie2LastLast.append(tail)
            
            trie2Last[trie2Last.count - 1] = trie2LastLast
            trie2[trie2.count - 1] = trie2Last
            return Vector(trie2)
        }
    }
    
    private func pop4(trie: Array4) -> (Vector, Array1) {
        if trie.last!.last!.count == 1 {
            if trie.last!.count == 1 {
                if trie.count == 2 {
                    return (Vector(trie[0]), trie.last!.last!.last!)
                } else {
                    var trie2 = trie
                    trie2.removeLast()
                    return (Vector(trie2), trie.last!.last!.last!)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                trie2Last.removeLast()
                trie2[trie2.count - 1] = trie2Last
                return (Vector(trie2), trie.last!.last!.last!)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            trie2Last.removeLast()
            var trie2LastLast = trie2Last.last!
            trie2LastLast.removeLast()
            
            trie2Last[trie2Last.count - 1] = trie2LastLast
            trie2[trie2.count - 1] = trie2Last
            
            return (Vector(trie2), trie.last!.last!.last!)
        }
    }
}

// MARK: - Level 5 operations

extension Vector {
    private func update5(trie: Array5, index: Int, obj: T) -> Vector {
        var trie2a = trie
        var trie2b = trie2a[(index >> 20) & 0x01]
        var trie2c = trie2b[(index >> 15) & 0x01]
        var trie2d = trie2c[(index >> 10) & 0x01]
        var trie2e = trie2d[(index >> 5) & 0x01]
        
        trie2e[index & 0x01] = obj
        trie2d[(index >> 5) & 0x01] = trie2e
        trie2c[(index >> 10) & 0x01] = trie2d
        trie2b[(index >> 15) & 0x01] = trie2c
        trie2a[(index >> 20) & 0x01] = trie2b
        return Vector(trie2a)
    }
    
    private func append5(trie: Array5, tail: Array1) -> Vector {
        if trie.last!.last!.last!.count >= 32 {
            if trie.last!.last!.count >= 32 {
                if trie.last!.count >= 32 {
                    if trie.count >= 32 {
                        var trie2 = Array6()
                        trie2.append(trie)
                        trie2.append(Array5())
                        
                        trie2[1].append(Array4())
                        trie2[1][0].append(Array3())
                        trie2[1][0][0].append(Array2())
                        trie2[1][0][0][0].append(tail)
                        
                        return Vector(trie2)
                    } else {
                        var trie2 = trie
                        trie2.append(Array4())
                        
                        var trie2Last = trie2.last!
                        trie2Last.append(Array3())
                        
                        var trie2LastLast = trie2Last.last!
                        trie2LastLast.append(Array2())
                        
                        var trie2LastLastLast = trie2LastLast.last!
                        trie2LastLastLast.append(tail)
                        
                        trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
                        trie2Last[trie2Last.count - 1] = trie2LastLast
                        trie2[trie2.count - 1] = trie2Last
                        
                        return Vector(trie2)
                    }
                } else {
                    var trie2 = trie
                    trie2.append(Array4())
                    
                    var trie2Last = trie2.last!
                    trie2Last.append(Array3())
                    
                    var trie2LastLast = trie2Last.last!
                    trie2LastLast.append(Array2())
                    
                    var trie2LastLastLast = trie2LastLast.last!
                    trie2LastLastLast.append(tail)
                    
                    trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
                    trie2Last[trie2Last.count - 1] = trie2LastLast
                    trie2[trie2.count - 1] = trie2Last
                    
                    return Vector(trie2)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                var trie2LastLast = trie2.last!.last!
                trie2LastLast.append(Array2())
                
                var trie2LastLastLast = trie2LastLast.last!
                trie2LastLastLast.append(tail)
                
                trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
                trie2Last[trie2Last.count - 1] = trie2LastLast
                trie2[trie2.count - 1] = trie2Last
                
                return Vector(trie2)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            var trie2LastLast = trie2Last.last!
            var trie2LastLastLast = trie2LastLast.last!
            
            trie2LastLastLast.append(tail)
            
            trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
            trie2Last[trie2Last.count - 1] = trie2LastLast
            trie2[trie2.count - 1] = trie2Last
            return Vector(trie2)
        }
    }
    
    private func pop5(trie: Array5) -> (Vector, Array1) {
        if trie.last!.last!.last!.count == 1 {
            if trie.last!.last!.count == 1 {
                if trie.last!.count == 1 {
                    if trie.count == 2 {
                        return (Vector(trie[0]), trie.last!.last!.last!.last!)
                    } else {
                        var trie2 = trie
                        trie2.removeLast()
                        return (Vector(trie2), trie.last!.last!.last!.last!)
                    }
                } else {
                    var trie2 = trie
                    var trie2Last = trie2.last!
                    trie2Last.removeLast()
                    trie2[trie2.count - 1] = trie2Last
                    return (Vector(trie2), trie.last!.last!.last!.last!)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                trie2Last.removeLast()
                
                var trie2LastLast = trie2Last.last!
                trie2LastLast.removeLast()
                
                trie2Last[trie2Last.count - 1] = trie2LastLast
                trie2[trie2.count - 1] = trie2Last
                return (Vector(trie2), trie.last!.last!.last!.last!)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            trie2Last.removeLast()
            var trie2LastLast = trie2Last.last!
            trie2LastLast.removeLast()
            
            var trie2LastLastLast = trie2LastLast.last!
            trie2LastLastLast.removeLast()
            
            trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
            trie2Last[trie2Last.count - 1] = trie2LastLast
            trie2[trie2.count - 1] = trie2Last
            
            return (Vector(trie2), trie.last!.last!.last!.last!)
        }
    }
}

// MARK: - Level 6 operations

extension Vector {
    private func update6(trie: Array6, index: Int, obj: T) -> Vector {
        var trie2a = trie
        var trie2b = trie2a[(index >> 25) & 0x01]
        var trie2c = trie2b[(index >> 20) & 0x01]
        var trie2d = trie2c[(index >> 15) & 0x01]
        var trie2e = trie2d[(index >> 10) & 0x01]
        var trie2f = trie2e[(index >> 5) & 0x01]
        
        trie2f[index & 0x01] = obj
        trie2e[(index >> 5) & 0x01] = trie2f
        trie2d[(index >> 10) & 0x01] = trie2e
        trie2c[(index >> 15) & 0x01] = trie2d
        trie2b[(index >> 20) & 0x01] = trie2c
        trie2a[(index >> 25) & 0x01] = trie2b
        return Vector(trie2a)
    }
    
    private func append6(trie: Array6, tail: Array1) -> Vector {
        if trie.last!.last!.last!.last!.count >= 32 {
            if trie.last!.last!.last!.count >= 32 {
                if trie.last!.last!.count >= 32 {
                    if trie.last!.count >= 32 {
                        if trie.count >= 32 {
                            assertionFailure("Cannot grow vector beyond integer bounds")
                            return Vector()
                        } else {
                            var trie2 = trie
                            trie2.append(Array5())
                            
                            var trie2Last = trie2.last!
                            trie2Last.append(Array4())
                            
                            var trie2LastLast = trie2Last.last!
                            trie2LastLast.append(Array3())
                            
                            var trie2LastLastLast = trie2LastLast.last!
                            trie2LastLastLast.append(Array2())
                            
                            var trie2LastLastLastLast = trie2LastLastLast.last!
                            trie2LastLastLastLast.append(tail)
                            
                            trie2LastLastLast[trie2LastLastLast.count - 1] = trie2LastLastLastLast
                            trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
                            trie2Last[trie2Last.count - 1] = trie2LastLast
                            trie2[trie2.count - 1] = trie2Last
                            
                            return Vector(trie2)
                        }
                    } else {
                        var trie2 = trie
                        var trie2Last = trie2.last!
                        
                        trie2Last.append(Array4())
                        
                        var trie2LastLast = trie2Last.last!
                        trie2LastLast.append(Array3())
                        
                        var trie2LastLastLast = trie2LastLast.last!
                        trie2LastLastLast.append(Array2())
                        
                        var trie2LastLastLastLast = trie2LastLastLast.last!
                        trie2LastLastLastLast.append(tail)
                        
                        trie2LastLastLast[trie2LastLastLast.count - 1] = trie2LastLastLastLast
                        trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
                        trie2Last[trie2Last.count - 1] = trie2LastLast
                        trie2[trie2.count - 1] = trie2Last
                        
                        return Vector(trie2)
                    }
                } else {
                    var trie2 = trie
                    var trie2Last = trie2.last!
                    var trie2LastLast = trie2Last.last!
                    
                    trie2LastLast.append(Array3())
                    
                    var trie2LastLastLast = trie2LastLast.last!
                    trie2LastLastLast.append(Array2())
                    
                    var trie2LastLastLastLast = trie2LastLastLast.last!
                    trie2LastLastLastLast.append(tail)
                    
                    trie2LastLastLast[trie2LastLastLast.count - 1] = trie2LastLastLastLast
                    trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
                    trie2Last[trie2Last.count - 1] = trie2LastLast
                    trie2[trie2.count - 1] = trie2Last
                    
                    return Vector(trie2)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                var trie2LastLast = trie2.last!.last!
                var trie2LastLastLast = trie2.last!.last!.last!
                
                trie2LastLastLast.append(Array2())
                
                var trie2LastLastLastLast = trie2LastLastLast.last!
                trie2LastLastLastLast.append(tail)
                
                trie2LastLastLast[trie2LastLastLast.count - 1] = trie2LastLastLastLast
                trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
                trie2Last[trie2Last.count - 1] = trie2LastLast
                trie2[trie2.count - 1] = trie2Last
                
                return Vector(trie2)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            var trie2LastLast = trie2Last.last!
            var trie2LastLastLast = trie2LastLast.last!
            var trie2LastLastLastLast = trie2LastLastLast.last!
            
            trie2LastLastLastLast.append(tail)
            
            trie2LastLastLast[trie2LastLastLast.count - 1] = trie2LastLastLastLast
            trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
            trie2Last[trie2Last.count - 1] = trie2LastLast
            trie2[trie2.count - 1] = trie2Last
            return Vector(trie2)
        }
    }
    
    private func pop6(trie: Array6) -> (Vector, Array1) {
        if trie.last!.last!.last!.last!.count == 1 {
            if trie.last!.last!.last!.count == 1 {
                if trie.last!.last!.count == 1 {
                    if trie.last!.count == 1 {
                        if trie.count == 2 {
                            return (Vector(trie[0]), trie.last!.last!.last!.last!.last!)
                        } else {
                            var trie2 = trie
                            trie2.removeLast()
                            return (Vector(trie2), trie.last!.last!.last!.last!.last!)
                        }
                    } else {
                        var trie2 = trie
                        var trie2Last = trie2.last!
                        trie2Last.removeLast()
                        
                        trie2[trie2.count - 1] = trie2Last
                        return (Vector(trie2), trie.last!.last!.last!.last!.last!)
                    }
                } else {
                    var trie2 = trie
                    var trie2Last = trie2.last!
                    trie2Last.removeLast()
                    
                    var trie2LastLast = trie2Last.last!
                    trie2LastLast.removeLast()
                    
                    trie2Last[trie2Last.count - 1] = trie2LastLast
                    trie2[trie2.count - 1] = trie2Last
                    return (Vector(trie2), trie.last!.last!.last!.last!.last!)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                trie2Last.removeLast()
                
                var trie2LastLast = trie2Last.last!
                trie2LastLast.removeLast()
                
                var trie2LastLastLast = trie2LastLast.last!
                trie2LastLastLast.removeLast()
                
                trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
                trie2Last[trie2Last.count - 1] = trie2LastLast
                trie2[trie2.count - 1] = trie2Last
                return (Vector(trie2), trie.last!.last!.last!.last!.last!)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            trie2Last.removeLast()
            
            var trie2LastLast = trie2Last.last!
            trie2LastLast.removeLast()
            
            var trie2LastLastLast = trie2LastLast.last!
            trie2LastLastLast.removeLast()
            
            var trie2LastLastLastLast = trie2LastLastLast.last!
            trie2LastLastLastLast.removeLast()
            
            trie2LastLastLast[trie2LastLastLast.count - 1] = trie2LastLastLastLast
            trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
            trie2Last[trie2Last.count - 1] = trie2LastLast
            trie2[trie2.count - 1] = trie2Last
            
            return (Vector(trie2), trie.last!.last!.last!.last!.last!)
        }
    }
}