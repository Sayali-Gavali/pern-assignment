import jwt from 'jsonwebtoken';
export function authenticate(req,res,next) {
 const header=req.headers.authorization;
 if(!header?.startsWith('Bearer ')) return res.status(401).json({error:'Authentication required'});
 try { req.user=jwt.verify(header.slice(7),process.env.JWT_SECRET); next(); }
 catch { return res.status(401).json({error:'Invalid or expired token'}); }
}
export const allowRoles=(...roles)=>(req,res,next)=>roles.includes(req.user?.role)?next():res.status(403).json({error:'Forbidden: insufficient role'});
